package entities

import (
	"database/sql"
	"time"

	"github.com/google/uuid"
)

type TeacherPerformance struct {
	ID                 uuid.UUID    `json:"id"`
	TenantID           uuid.UUID    `json:"tenant_id"`
	StaffID          uuid.UUID    `json:"staff_id"`
	Category           string       `json:"category"`
	Title              string       `json:"title"`
	FileURL            string       `json:"file_url"`
	Description        string       `json:"description"`
	VerificationStatus string       `json:"verification_status"` // Assuming LeaveStatus is defined elsewhere
	VerifiedBy         uuid.UUID    `json:"verified_by"`
	CreatedAt          time.Time    `json:"created_at"`
	UpdatedAt          sql.NullTime `json:"updated_at"`
	DeletedAt          sql.NullTime `json:"deleted_at"`
}
