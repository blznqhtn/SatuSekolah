package entities

import (
	"database/sql"
	"time"

	"github.com/google/uuid"
)

type SpmbStatus string

const (
	SpmbPending        SpmbStatus = "PENDING"
	SpmbDocumentReview SpmbStatus = "DOCUMENT_REVIEW"
	SpmbTest           SpmbStatus = "TEST"
	SpmbAccepted       SpmbStatus = "ACCEPTED"
	SpmbRejected       SpmbStatus = "REJECTED"
)

type SchoolFacility struct {
	ID          uuid.UUID    `json:"id"`
	TenantID    uuid.UUID    `json:"tenant_id"`
	Name        string       `json:"name"`
	Description string       `json:"description"`
	PhotoURL    string       `json:"photo_url"`
	CreatedAt   time.Time    `json:"created_at"`
	UpdatedAt   sql.NullTime `json:"updated_at"`
	DeletedAt   sql.NullTime `json:"deleted_at"`
}

type SpmbBatch struct {
	ID              uuid.UUID    `json:"id"`
	TenantID        uuid.UUID    `json:"tenant_id"`
	Name            string       `json:"name"`
	Description     string       `json:"description"`
	StartDate       time.Time    `json:"start_date"`
	EndDate         time.Time    `json:"end_date"`
	RegistrationFee float64      `json:"registration_fee"`
	IsActive        bool         `json:"is_active"`
	CreatedAt       time.Time    `json:"created_at"`
	UpdatedAt       sql.NullTime `json:"updated_at"`
	DeletedAt       sql.NullTime `json:"deleted_at"`
}
