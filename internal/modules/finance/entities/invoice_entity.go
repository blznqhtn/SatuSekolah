package entities

import (
	"database/sql"
	"time"

	"github.com/google/uuid"
)

type InvoiceStatus string

const (
	Pending InvoiceStatus = "PENDING"
	Partial InvoiceStatus = "PARTIAL"
	Paid    InvoiceStatus = "PAID"
)

type StudentInvoice struct {
	ID          uuid.UUID     `json:"id"`
	TenantID    uuid.UUID     `json:"tenant_id"`
	StudentID   uuid.UUID     `json:"student_id"`
	FeeID       uuid.UUID     `json:"fee_id"`
	InvoiceName string        `json:"invoice_name"`
	TotalAmount float64       `json:"total_amount"`
	PaidAmount  float64       `json:"paid_amount"`
	Status      InvoiceStatus `json:"status"`
	DueDate     time.Time     `json:"due_date"`
	CreatedAt   time.Time     `json:"created_at"`
	UpdatedAt   sql.NullTime  `json:"updated_at"`
	DeletedAt   sql.NullTime  `json:"deleted_at"`
	UpdatedBy   uuid.UUID     `json:"updated_by"`
}

type InvoicePayment struct {
	ID             uuid.UUID `json:"id"`
	InvoiceID      uuid.UUID `json:"invoice_id"`
	WalletLedgerID uuid.UUID `json:"wallet_ledger_id"`
	PaidAmount     float64   `json:"paid_amount"`
	PaidAt         time.Time `json:"paid_at"`
}
