package entities

import (
	"database/sql"
	"time"

	"github.com/google/uuid"
)

type SpmbRegistration struct {
	ID                 uuid.UUID    `json:"id"`
	TenantID           uuid.UUID    `json:"tenant_id"`
	ParentID           uuid.UUID    `json:"parent_id"`
	SpmbBatchID        uuid.UUID    `json:"spmb_batch_id"`
	MajorID            uuid.UUID    `json:"major_id"`
	InvoiceID          uuid.UUID    `json:"invoice_id"`
	StudentName        string       `json:"student_name"`
	PreviousSchool     string       `json:"previous_school"`
	RegistrationStatus string       `json:"registration_status"` // Assuming SpmbStatus is defined elsewhere
	CreatedAt          time.Time    `json:"created_at"`
	UpdatedAt          sql.NullTime `json:"updated_at"`
	DeletedAt          sql.NullTime `json:"deleted_at"`
	UpdatedBy          uuid.UUID    `json:"updated_by"`
}

type DirectMessage struct {
	ID               uuid.UUID    `json:"id"`
	TenantID         uuid.UUID    `json:"tenant_id"`
	SenderID         uuid.UUID    `json:"sender_id"`
	ReceiverID       uuid.UUID    `json:"receiver_id"`
	EncryptedContent string       `json:"encrypted_content"`
	IsRead           bool         `json:"is_read"`
	CreatedAt        time.Time    `json:"created_at"`
	DeletedAt        sql.NullTime `json:"deleted_at"`
}
