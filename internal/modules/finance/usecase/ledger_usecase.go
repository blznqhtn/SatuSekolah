package usecase

import (
	"context"
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"fmt"
	"time"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/finance/domain"
	coreDomain "neuracakrawira.asia/satu-sekolah-backend/internal/modules/core/domain"
	canteenDomain "neuracakrawira.asia/satu-sekolah-backend/internal/modules/canteen/domain"
	"neuracakrawira.asia/satu-sekolah-backend/pkg/crypto"
)

type ledgerUsecase struct {
	repo        domain.LedgerRepository
	coreRepo    coreDomain.CoreRepository
	canteenRepo canteenDomain.CanteenRepository
	billingRepo domain.BillingRepository
	hmacSecret  string
}

// NewLedgerUsecase creates a new instance of LedgerUsecase
func NewLedgerUsecase(repo domain.LedgerRepository, coreRepo coreDomain.CoreRepository, canteenRepo canteenDomain.CanteenRepository, billingRepo domain.BillingRepository, hmacSecret string) domain.LedgerUsecase {
	return &ledgerUsecase{
		repo:        repo,
		coreRepo:    coreRepo,
		canteenRepo: canteenRepo,
		billingRepo: billingRepo,
		hmacSecret:  hmacSecret,
	}
}

func (u *ledgerUsecase) RecordTransaction(ctx context.Context, req *domain.WalletLedger) (*domain.WalletLedger, error) {
	// 1. Get the latest ledger for this user to get the PreviousHash
	latest, err := u.repo.GetLatestLedger(ctx, req.TenantID, req.UserID)
	if err != nil {
		return nil, err
	}

	// 2. Set Previous Hash (genesis block concept if no previous transaction)
	if latest == nil {
		req.PreviousHash = "GENESIS_HASH_0000000000000000000000000000000000000000000000000"
	} else {
		req.PreviousHash = latest.CurrentHash
	}

	// 3. Generate ID early for hashing
	if req.ID == uuid.Nil {
		req.ID = uuid.New()
	}

	// 4. Set timestamp early for hashing
	currentTime := time.Now().UTC()
	req.CreatedAt = currentTime

	// 5. Generate Current Hash (Web3 Principle)
	timestampStr := req.CreatedAt.Format(time.RFC3339Nano)
	req.CurrentHash = crypto.GenerateLedgerHash(u.hmacSecret, req.PreviousHash, req.Amount, timestampStr, req.ID.String())

	// 6. Append to Immutable Ledger
	err = u.repo.AppendLedger(ctx, req)
	if err != nil {
		return nil, err
	}

	return req, nil
}

func (u *ledgerUsecase) ProcessTopup(ctx context.Context, tenantID, userID uuid.UUID, grossAmount float64) (*domain.WalletLedger, error) {
	// Topup fee logic: Gateway fee (e.g. QRIS 2% or flat 4000) + 1000 margin.
	// We will simplify to a flat 4000 gateway + 1000 margin = 5000 total fee.
	// The fee is deducted from the gross amount.
	totalFee := 5000.0
	netAmount := grossAmount - totalFee

	if netAmount <= 0 {
		return nil, errors.New("topup amount is too low to cover fees")
	}

	refType := domain.RefTopup
	ledger := &domain.WalletLedger{
		TenantID:        tenantID,
		UserID:          userID,
		TransactionType: domain.TxCredit,
		Amount:          netAmount,
		Fee:             totalFee,
		ReferenceType:   &refType,
	}

	var savedLedger *domain.WalletLedger
	err := u.repo.ExecTx(ctx, func(txRepo domain.LedgerRepository) error {
		// Temporary usecase using the tx repo for this atomic op
		txUsecase := &ledgerUsecase{repo: txRepo, hmacSecret: u.hmacSecret}
		
		res, err := txUsecase.RecordTransaction(ctx, ledger)
		if err != nil {
			return err
		}
		savedLedger = res

		// Update aggregated balance
		balance, err := txRepo.GetAggregatedBalance(ctx, userID)
		if err != nil {
			return err
		}
		return txRepo.UpdateCachedBalance(ctx, userID, balance)
	})

	return savedLedger, err
}

func (u *ledgerUsecase) ProcessWithdrawal(ctx context.Context, tenantID, userID uuid.UUID, grossAmount float64) (*domain.WalletLedger, error) {
	// Withdrawal (IRIS) logic: 5000 base fee + 5% margin
	// The fee is deducted from the grossAmount. 
	// E.g., user withdraws 200k -> 200k is deducted from wallet, fee is 15k, payout to bank is 185k.
	margin := grossAmount * 0.05
	totalFee := 5000.0 + margin
	netPayout := grossAmount - totalFee

	if netPayout <= 0 {
		return nil, errors.New("withdrawal amount is too low to cover fees")
	}

	refType := domain.RefWithdrawal
	ledger := &domain.WalletLedger{
		TenantID:        tenantID,
		UserID:          userID,
		TransactionType: domain.TxDebit,
		Amount:          grossAmount, // The total amount debited from the wallet
		Fee:             totalFee,
		ReferenceType:   &refType,
	}

	var savedLedger *domain.WalletLedger
	err := u.repo.ExecTx(ctx, func(txRepo domain.LedgerRepository) error {
		// Check balance first
		currentBalance, err := txRepo.GetAggregatedBalance(ctx, userID)
		if err != nil {
			return err
		}

		if currentBalance < grossAmount {
			return errors.New("insufficient balance for withdrawal")
		}

		txUsecase := &ledgerUsecase{repo: txRepo, hmacSecret: u.hmacSecret}
		res, err := txUsecase.RecordTransaction(ctx, ledger)
		if err != nil {
			return err
		}
		savedLedger = res

		newBalance, err := txRepo.GetAggregatedBalance(ctx, userID)
		if err != nil {
			return err
		}
		return txRepo.UpdateCachedBalance(ctx, userID, newBalance)
	})

	return savedLedger, err
}

// internalTransferWithDesc is a helper to transfer money between two users with a custom description
func (u *ledgerUsecase) internalTransferWithDesc(ctx context.Context, tenantID, senderID, receiverID uuid.UUID, amount float64, description string) error {
	return u.repo.ExecTx(ctx, func(txRepo domain.LedgerRepository) error {
		// 1. Debit Sender
		refType := "P2P_TRANSFER"
		ledgerDebit := &domain.WalletLedger{
			ID:              uuid.New(),
			TenantID:        tenantID,
			UserID:          senderID,
			TransactionType: domain.TxDebit,
			Amount:          amount,
			ReferenceType:   &refType,
			ReferenceID:     &receiverID,
			Description:     description,
		}
		txUsecase := &ledgerUsecase{repo: txRepo, hmacSecret: u.hmacSecret}
		if _, err := txUsecase.RecordTransaction(ctx, ledgerDebit); err != nil {
			return err
		}

		// 2. Credit Receiver
		ledgerCredit := &domain.WalletLedger{
			ID:              uuid.New(),
			TenantID:        tenantID,
			UserID:          receiverID,
			TransactionType: domain.TxCredit,
			Amount:          amount,
			ReferenceType:   &refType,
			ReferenceID:     &senderID,
			Description:     description,
		}
		if _, err := txUsecase.RecordTransaction(ctx, ledgerCredit); err != nil {
			return err
		}

		// Sync both balances
		newSenderBalance, _ := txRepo.GetAggregatedBalance(ctx, senderID)
		_ = txRepo.UpdateCachedBalance(ctx, senderID, newSenderBalance)

		newReceiverBalance, _ := txRepo.GetAggregatedBalance(ctx, receiverID)
		_ = txRepo.UpdateCachedBalance(ctx, receiverID, newReceiverBalance)

		return nil
	})
}

// InternalTransfer allows system components to securely transfer money without PIN validation
func (u *ledgerUsecase) InternalTransfer(ctx context.Context, tenantID, senderID, receiverID uuid.UUID, amount float64) error {
	return u.internalTransferWithDesc(ctx, tenantID, senderID, receiverID, amount, "Transfer Saldo")
}

func (u *ledgerUsecase) hashPIN(pin string) string {
	h := hmac.New(sha256.New, []byte(u.hmacSecret))
	h.Write([]byte(pin))
	return hex.EncodeToString(h.Sum(nil))
}

func (u *ledgerUsecase) verifyPIN(ctx context.Context, userID uuid.UUID, pin string) error {
	user, err := u.coreRepo.GetUserByID(ctx, userID)
	if err != nil {
		return err
	}
	if user == nil {
		return errors.New("user not found")
	}
	if user.PinHash == "" {
		return errors.New("PIN is not set for this user")
	}
	if user.PinHash != u.hashPIN(pin) {
		return errors.New("invalid PIN")
	}
	return nil
}

func (u *ledgerUsecase) TransferP2P(ctx context.Context, tenantID, senderID uuid.UUID, targetAccountNumber string, amount float64, pin string) error {
	if err := u.verifyPIN(ctx, senderID, pin); err != nil {
		return err
	}

	if amount <= 0 {
		return errors.New("transfer amount must be greater than zero")
	}

	// Intercept Canteen VA (length > 12 typically)
	if len(targetAccountNumber) > 12 {
		// 1. Cek apakah ini VA Tagihan / Billing
		inv, err := u.billingRepo.GetInvoiceByTransferAccount(ctx, targetAccountNumber)
		if err == nil && inv != nil {
			if inv.Status == "PAID" {
				return errors.New("tagihan sudah lunas")
			}
			if inv.Status == "EXPIRED" {
				return errors.New("tagihan sudah kedaluwarsa")
			}
			if inv.DueDate != nil && time.Now().After(*inv.DueDate) {
				_ = u.billingRepo.UpdateInvoiceStatus(ctx, inv.ID, inv.PaidAmount, "EXPIRED")
				return errors.New("tagihan sudah kedaluwarsa")
			}
			remaining := inv.TotalAmount - inv.PaidAmount
			if amount > remaining {
				return fmt.Errorf("jumlah transfer melebihi sisa tagihan (Rp %.0f)", remaining)
			}
			if amount < remaining {
				if !inv.CanInstallment {
					return errors.New("tagihan ini tidak bisa dicicil, harus dibayar penuh")
				}
				if inv.MinimumInstallment > 0 && amount < inv.MinimumInstallment {
					return fmt.Errorf("minimal cicilan adalah Rp %.0f", inv.MinimumInstallment)
				}
			}

			// Bayar tagihan via Ledger Debit
			refType := "INVOICE_PAYMENT"
			invID := inv.ID
			desc := fmt.Sprintf("Bayar Tagihan via Transfer VA: %s", inv.InvoiceName)
			ledgerReq := &domain.WalletLedger{
				ID:              uuid.New(),
				TenantID:        tenantID,
				UserID:          senderID,
				TransactionType: domain.TxDebit,
				Amount:          amount,
				ReferenceType:   &refType,
				ReferenceID:     &invID,
				Description:     desc,
			}
			ledgerRes, err := u.RecordTransaction(ctx, ledgerReq)
			if err != nil {
				return err
			}

			newPaidTotal := inv.PaidAmount + amount
			newStatus := "PARTIAL"
			if newPaidTotal >= inv.TotalAmount {
				newStatus = "PAID"
			}
			if err := u.billingRepo.UpdateInvoiceStatus(ctx, inv.ID, newPaidTotal, newStatus); err != nil {
				return err
			}
			return u.billingRepo.RecordPayment(ctx, inv.ID, ledgerRes.ID, amount)
		}

		// 2. Cek apakah ini VA Kantin
		order, err := u.canteenRepo.GetOrderByTransferAccount(ctx, targetAccountNumber)
		if err == nil && order != nil {
			if order.Status != canteenDomain.OrderStatusPending {
				return errors.New("canteen order is no longer pending")
			}
			if order.ExpiresAt != nil && time.Now().After(*order.ExpiresAt) {
				return errors.New("canteen order payment code has expired")
			}
			if amount < order.TotalAmount {
				return errors.New("amount is less than canteen order total")
			}
			
			// Pay Canteen Order
			shop, err := u.canteenRepo.GetShopByID(ctx, order.ShopID)
			if err != nil || shop == nil {
				return errors.New("canteen shop not found")
			}

			return u.canteenRepo.ExecTx(ctx, func(txRepo canteenDomain.CanteenRepository) error {
				desc := fmt.Sprintf("Bayar Jajan di Kantin: %s", shop.Name)
				err := u.internalTransferWithDesc(ctx, tenantID, senderID, shop.OwnerID, amount, desc)
				if err != nil {
					return err
				}

				order.BuyerID = &senderID
				if err := txRepo.UpdateOrderStatus(ctx, order.ID, canteenDomain.OrderStatusCompleted); err != nil {
					return err
				}
				return nil
			})
		}
	}

	// Regular P2P Transfer
	targetUser, err := u.coreRepo.GetUserByAccountNumber(ctx, targetAccountNumber)
	if err != nil {
		return err
	}
	if targetUser == nil {
		return errors.New("target account not found")
	}

	return u.InternalTransfer(ctx, tenantID, senderID, targetUser.ID, amount)
}

// VerifyLedgerIntegrity is a utility to verify if a user's entire transaction history has been tampered with
func (u *ledgerUsecase) VerifyLedgerIntegrity(ctx context.Context, tenantID, userID uuid.UUID) (bool, error) {
	// In a real implementation, you would fetch ALL ledgers for this user,
	// order them by CreatedAt ASC, and recalculate the hashes sequentially 
	// to ensure PreviousHash and CurrentHash match perfectly.
	// For now, this is a placeholder returning true.
	return true, nil
}

// GetTransactionHistory returns all wallet ledger entries for a user.
// The frontend is responsible for rendering this into a downloadable PDF report.
func (u *ledgerUsecase) GetTransactionHistory(ctx context.Context, tenantID, userID uuid.UUID) ([]*domain.WalletLedger, error) {
	return u.repo.GetTransactionHistory(ctx, tenantID, userID)
}

