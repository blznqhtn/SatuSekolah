package domain

import (
	"context"
	"time"

	"github.com/google/uuid"
)

type SpmbBatch struct {
	ID              uuid.UUID `json:"id"`
	TenantID        uuid.UUID `json:"tenant_id"`
	Name            string    `json:"name"`
	Description     string    `json:"description"`
	StartDate       time.Time `json:"start_date"`
	EndDate         time.Time `json:"end_date"`
	IsActive        bool      `json:"is_active"`
	CreatedAt       time.Time `json:"created_at"`
	UpdatedAt       time.Time `json:"updated_at"`
}

type SpmbBatchMajor struct {
	ID                uuid.UUID `json:"id"`
	SpmbBatchID       uuid.UUID `json:"spmb_batch_id"`
	MajorID           uuid.UUID `json:"major_id"`
	RegistrationFee   float64   `json:"registration_fee"`
	ReRegistrationFee float64   `json:"re_registration_fee"`
	CreatedAt         time.Time `json:"created_at"`
}

type SpmbRegistration struct {
	ID                 uuid.UUID  `json:"id"`
	TenantID           uuid.UUID  `json:"tenant_id"`
	ParentID           uuid.UUID  `json:"parent_id"`
	SpmbBatchID        *uuid.UUID `json:"spmb_batch_id"`
	MajorID            *uuid.UUID `json:"major_id"`
	SecondMajorID      *uuid.UUID `json:"second_major_id"` // Optional
	InvoiceID          *uuid.UUID `json:"invoice_id"`      // Link to re-registration invoice

	// Student Details
	StudentName        string     `json:"student_name"`
	NISN               string     `json:"nisn"`
	PreviousSchool     string     `json:"previous_school"`
	Region             string     `json:"region"`
	Gender             string     `json:"gender"`
	Religion           string     `json:"religion"`
	PhotoURL           string     `json:"photo_url"`
	StudentPhone       string     `json:"student_phone"`

	// Parent Details
	FatherName         string     `json:"father_name"`
	MotherName         string     `json:"mother_name"`
	FatherPhone        string     `json:"father_phone"`
	MotherPhone        string     `json:"mother_phone"`
	FatherJob          string     `json:"father_job"`
	MotherJob          string     `json:"mother_job"`
	FatherIncome       string     `json:"father_income"`
	MotherIncome       string     `json:"mother_income"`

	// Status & Exam
	RegistrationStatus string     `json:"registration_status"`
	ExamSchedule       *time.Time `json:"exam_schedule"`

	CreatedAt          time.Time  `json:"created_at"`
	UpdatedAt          time.Time  `json:"updated_at"`
	UpdatedBy          *uuid.UUID `json:"updated_by"`
}

// Structs for Public Viewing
type PublicSchoolInfo struct {
	ID          uuid.UUID `json:"id"`
	Name        string    `json:"name"`
	Address     string    `json:"address"`
	LogoURL     string    `json:"logo_url"`
}

type SpmbRepository interface {
	GetPublicSchools(ctx context.Context) ([]*PublicSchoolInfo, error)
	CreateRegistration(ctx context.Context, reg *SpmbRegistration) error
	UpdateRegistrationStatus(ctx context.Context, id uuid.UUID, status string) error
}

type SpmbUsecase interface {
	GetPublicSchools(ctx context.Context) ([]*PublicSchoolInfo, error)
	RegisterSpmb(ctx context.Context, reg *SpmbRegistration) error
	UpdateRegistrationStatus(ctx context.Context, id uuid.UUID, status string) error
}
