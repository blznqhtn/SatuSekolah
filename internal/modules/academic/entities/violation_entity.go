package entities

import (
	"database/sql"
	"time"

	"github.com/google/uuid"
)

type ViolationType struct {
	ID          uuid.UUID    `json:"id"`
	TenantID    uuid.UUID    `json:"tenant_id"`
	Name        string       `json:"name"`
	PointWeight int          `json:"point_weight"`
	CreatedAt   time.Time    `json:"created_at"`
	DeletedAt   sql.NullTime `json:"deleted_at"`
}

type StudentViolation struct {
	ID              uuid.UUID    `json:"id"`
	TenantID        uuid.UUID    `json:"tenant_id"`
	StudentID       uuid.UUID    `json:"student_id"`
	ViolationTypeID uuid.UUID    `json:"violation_type_id"`
	ReportedBy      uuid.UUID    `json:"reported_by"`
	Notes           string       `json:"notes"`
	CreatedAt       time.Time    `json:"created_at"`
	UpdatedAt       sql.NullTime `json:"updated_at"`
	DeletedAt       sql.NullTime `json:"deleted_at"`
}
