package entities

import (
	"database/sql"
	"time"

	"github.com/google/uuid"
)

type FeeType struct {
	ID           uuid.UUID    `json:"id"`
	TenantID     uuid.UUID    `json:"tenant_id"`
	Name         string       `json:"name"`
	BillingCycle string       `json:"billing_cycle"`
	CreatedAt    time.Time    `json:"created_at"`
	UpdatedAt    sql.NullTime `json:"updated_at"`
	DeletedAt    sql.NullTime `json:"deleted_at"`
}

type Fee struct {
	ID         uuid.UUID     `json:"id"`
	FeeTypeID  uuid.UUID     `json:"fee_type_id"`
	MajorID    uuid.NullUUID `json:"major_id"`
	GradeLevel sql.NullInt32 `json:"grade_level"`
	Amount     float64       `json:"amount"`
	CreatedAt  time.Time     `json:"created_at"`
	UpdatedAt  sql.NullTime  `json:"updated_at"`
	DeletedAt  sql.NullTime  `json:"deleted_at"`
	UpdatedBy  uuid.UUID     `json:"updated_by"`
}
