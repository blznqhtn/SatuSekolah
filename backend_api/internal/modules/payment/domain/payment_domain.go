package domain

import (
	"context"
	"time"

	"github.com/google/uuid"
)

type PaymentCategory struct {
	ID          uuid.UUID `json:"id"`
	TenantID    uuid.UUID `json:"tenant_id"`
	Name        string    `json:"name"`
	Description string    `json:"description"`
}

type PaymentBill struct {
	ID          uuid.UUID             `json:"id"`
	TenantID    uuid.UUID             `json:"tenant_id"`
	StudentID   uuid.UUID             `json:"student_id"`
	CategoryID  uuid.UUID             `json:"category_id"`
	Title       string                `json:"title"`
	TotalAmount float64               `json:"total_amount"`
	PaidAmount  float64               `json:"paid_amount"`
	Status      string                `json:"status"` // PENDING, PAID, EXPIRED
	DueDate     string                `json:"due_date"`
	CreatedAt   time.Time             `json:"created_at"`
	UpdatedAt   time.Time             `json:"updated_at"`
	Details     []*PaymentBillDetail  `json:"details,omitempty"`
	Category    *PaymentCategory      `json:"category,omitempty"`
}

type PaymentBillDetail struct {
	ID          uuid.UUID `json:"id"`
	BillID      uuid.UUID `json:"bill_id"`
	ItemName    string    `json:"item_name"`
	Amount      float64   `json:"amount"`
	IsDeduction bool      `json:"is_deduction"`
}

type PaymentTransaction struct {
	ID            uuid.UUID `json:"id"`
	TenantID      uuid.UUID `json:"tenant_id"`
	BillID        uuid.UUID `json:"bill_id"`
	StudentID     uuid.UUID `json:"student_id"`
	Amount        float64   `json:"amount"`
	PaymentMethod string    `json:"payment_method"`
	ReferenceNo   *string   `json:"reference_no"`
	Status        string    `json:"status"`
	PaidAt        time.Time `json:"paid_at"`
	CreatedAt     time.Time `json:"created_at"`

	BillTitle string `json:"bill_title,omitempty"`
}

type PaymentRepository interface {
	GetActiveBills(ctx context.Context, tenantID, studentID uuid.UUID) ([]*PaymentBill, error)
	GetBillDetails(ctx context.Context, billID uuid.UUID) ([]*PaymentBillDetail, error)
	GetTransactions(ctx context.Context, tenantID, studentID uuid.UUID) ([]*PaymentTransaction, error)
	UpdateBillStatus(ctx context.Context, billID uuid.UUID, paidAmount float64, status string) error
	CreateTransaction(ctx context.Context, trx *PaymentTransaction) error
	GetBillByID(ctx context.Context, billID uuid.UUID) (*PaymentBill, error)
}

type PaymentUsecase interface {
	GetActiveBills(ctx context.Context, tenantID, studentID uuid.UUID) ([]*PaymentBill, error)
	GetTransactions(ctx context.Context, tenantID, studentID uuid.UUID) ([]*PaymentTransaction, error)
	PayBill(ctx context.Context, tenantID, studentID, billID uuid.UUID, amount float64, paymentMethod, pin string) error
}
