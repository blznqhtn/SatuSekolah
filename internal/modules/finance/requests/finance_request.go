package requests

import "github.com/google/uuid"

type ProcessTransactionRequest struct {
	TenantID      string  `json:"tenant_id" validate:"required,uuid"`
	UserID        string  `json:"user_id" validate:"required,uuid"`
	TransactionType string  `json:"transaction_type" validate:"required"`
	Amount        float64 `json:"amount" validate:"required,gt=0"`
	ReferenceType string  `json:"reference_type" validate:"required"`
	ReferenceID   string  `json:"reference_id" validate:"required,uuid"`
}

type CreateFeeRequest struct {
	FeeTypeID  string    `json:"fee_type_id" validate:"required,uuid"`
	MajorID    uuid.NullUUID `json:"major_id" validate:"omitempty,uuid"`
	GradeLevel int       `json:"grade_level"`
	Amount     float64   `json:"amount" validate:"required,gt=0"`
	UpdatedBy  string    `json:"updated_by" validate:"required,uuid"`
}

type CreateInvoiceRequest struct {
	TenantID    string  `json:"tenant_id" validate:"required,uuid"`
	StudentID   string  `json:"student_id" validate:"required,uuid"`
	FeeID       string  `json:"fee_id" validate:"required,uuid"`
	InvoiceName string  `json:"invoice_name" validate:"required"`
	TotalAmount float64 `json:"total_amount" validate:"required,gt=0"`
	DueDate     string  `json:"due_date" validate:"required"`
	UpdatedBy   string  `json:"updated_by" validate:"required,uuid"`
}

type ProcessPaymentRequest struct {
	InvoiceID  string  `json:"invoice_id" validate:"required,uuid"`
	PaidAmount float64 `json:"paid_amount" validate:"required,gt=0"`
}

type CreateReimbursementRequest struct {
	TenantID       string  `json:"tenant_id" validate:"required,uuid"`
	UserID         string  `json:"user_id" validate:"required,uuid"`
	Amount         float64 `json:"amount" validate:"required,gt=0"`
	Description    string  `json:"description" validate:"required"`
	ReceiptFileURL string  `json:"receipt_file_url" validate:"required,url"`
}
