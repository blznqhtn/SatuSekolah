package domain

import (
	"context"
	"time"

	"github.com/google/uuid"
)

type TransactionType string

const (
	TxCredit TransactionType = "CREDIT"
	TxDebit  TransactionType = "DEBIT"
)

// Standard Reference Types
const (
	RefTopup        = "TOPUP"
	RefWithdrawal   = "WITHDRAWAL"
	RefTransferOut  = "TRANSFER_OUT"
	RefTransferIn   = "TRANSFER_IN"
	RefPayment      = "PAYMENT" // e.g. Kantin, SPP
	RefPayroll      = "PAYROLL"
)

// WalletLedger represents the Web3 Immutable Ledger table
type WalletLedger struct {
	ID              uuid.UUID       `json:"id"`
	TenantID        uuid.UUID       `json:"tenant_id"`
	UserID          uuid.UUID       `json:"user_id"`
	TransactionType TransactionType `json:"transaction_type"`
	Amount          float64         `json:"amount"`
	Fee             float64         `json:"fee"`
	ReferenceType   *string         `json:"reference_type"`
	ReferenceID     *uuid.UUID      `json:"reference_id"`
	Description     string          `json:"description,omitempty"`
	PreviousHash    string          `json:"previous_hash"`
	CurrentHash     string          `json:"current_hash"`
	CreatedAt       time.Time       `json:"created_at"`
}

// LedgerRepository defines database operations for the Web3 Ledger
type LedgerRepository interface {
	ExecTx(ctx context.Context, fn func(repo LedgerRepository) error) error

	// GetLatestLedger returns the most recent ledger entry for a user to get the PreviousHash
	GetLatestLedger(ctx context.Context, tenantID, userID uuid.UUID) (*WalletLedger, error)
	
	// AppendLedger purely appends a new transaction. (No update/delete allowed).
	AppendLedger(ctx context.Context, ledger *WalletLedger) error

	// UpdateCachedBalance updates the balance column in the users table
	UpdateCachedBalance(ctx context.Context, userID uuid.UUID, newBalance float64) error

	// GetAggregatedBalance calculates the true balance purely from ledger sums
	GetAggregatedBalance(ctx context.Context, userID uuid.UUID) (float64, error)

	// GetTransactionHistory returns all ledger entries for a user (for PDF report)
	GetTransactionHistory(ctx context.Context, tenantID, userID uuid.UUID) ([]*WalletLedger, error)
}

// LedgerUsecase handles the business logic and cryptographic hashing
type LedgerUsecase interface {
	ProcessTopup(ctx context.Context, tenantID, userID uuid.UUID, grossAmount float64) (*WalletLedger, error)
	ProcessWithdrawal(ctx context.Context, tenantID, userID uuid.UUID, amount float64) (*WalletLedger, error)
	InternalTransfer(ctx context.Context, tenantID, senderID, receiverID uuid.UUID, amount float64) error
	TransferP2P(ctx context.Context, tenantID, senderID uuid.UUID, targetAccountNumber string, amount float64, pin string) error

	RecordTransaction(ctx context.Context, req *WalletLedger) (*WalletLedger, error)
	VerifyLedgerIntegrity(ctx context.Context, tenantID, userID uuid.UUID) (bool, error)

	// GetTransactionHistory returns all wallet transactions for export to PDF
	GetTransactionHistory(ctx context.Context, tenantID, userID uuid.UUID) ([]*WalletLedger, error)
}
