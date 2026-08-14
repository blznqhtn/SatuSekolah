package usecase

import (
	"context"
	"fmt"
	"time"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/payment/domain"
)

type paymentUsecase struct {
	repo domain.PaymentRepository
}

func NewPaymentUsecase(repo domain.PaymentRepository) domain.PaymentUsecase {
	return &paymentUsecase{repo: repo}
}

func (u *paymentUsecase) GetActiveBills(ctx context.Context, tenantID, studentID uuid.UUID) ([]*domain.PaymentBill, error) {
	bills, err := u.repo.GetActiveBills(ctx, tenantID, studentID)
	if err != nil {
		return nil, err
	}

	for _, b := range bills {
		details, err := u.repo.GetBillDetails(ctx, b.ID)
		if err == nil {
			b.Details = details
		} else {
			b.Details = []*domain.PaymentBillDetail{}
		}
	}
	return bills, nil
}

func (u *paymentUsecase) GetTransactions(ctx context.Context, tenantID, studentID uuid.UUID) ([]*domain.PaymentTransaction, error) {
	return u.repo.GetTransactions(ctx, tenantID, studentID)
}

func (u *paymentUsecase) PayBill(ctx context.Context, tenantID, studentID, billID uuid.UUID, amount float64, paymentMethod, pin string) error {
	// 1. Verify Bill
	b, err := u.repo.GetBillByID(ctx, billID)
	if err != nil {
		return fmt.Errorf("bill not found")
	}

	if b.TenantID != tenantID || b.StudentID != studentID {
		return fmt.Errorf("unauthorized")
	}

	if b.Status == "PAID" {
		return fmt.Errorf("bill is already paid")
	}

	// In real life, here we should check the user's PIN vs their ledger or bank API.
	// We'll assume the PIN is valid and amount covers it for this simulation.

	// 2. Create Transaction
	ref := fmt.Sprintf("TRX-%d", time.Now().Unix())
	trx := &domain.PaymentTransaction{
		ID:            uuid.New(),
		TenantID:      tenantID,
		BillID:        billID,
		StudentID:     studentID,
		Amount:        amount,
		PaymentMethod: paymentMethod,
		ReferenceNo:   &ref,
		Status:        "SUCCESS",
		PaidAt:        time.Now(),
		CreatedAt:     time.Now(),
	}

	if err := u.repo.CreateTransaction(ctx, trx); err != nil {
		return err
	}

	// 3. Update Bill Status
	newPaid := b.PaidAmount + amount
	status := "PENDING"
	if newPaid >= b.TotalAmount {
		status = "PAID"
	}

	return u.repo.UpdateBillStatus(ctx, billID, newPaid, status)
}
