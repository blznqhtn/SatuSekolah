package entities

import (
	"database/sql"
	"time"

	"github.com/google/uuid"
)

type Reimbursement struct {
	ID             uuid.UUID    `json:"id"`
	TenantID       uuid.UUID    `json:"tenant_id"`
	UserID         uuid.UUID    `json:"user_id"`
	Amount         float64      `json:"amount"`
	Description    string       `json:"description"`
	ReceiptFileURL string       `json:"receipt_file_url"`
	Status         string       `json:"status"` // Assuming LeaveStatus is defined elsewhere
	ApprovedBy     uuid.UUID    `json:"approved_by"`
	ApprovedAt     sql.NullTime `json:"approved_at"`
	CreatedAt      time.Time    `json:"created_at"`
	UpdatedAt      sql.NullTime `json:"updated_at"`
}
