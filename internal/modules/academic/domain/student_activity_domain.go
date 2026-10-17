package domain

import (
	"context"
	"time"

	"github.com/google/uuid"
)

// ==========================================
// STUDENT PERMIT DOMAIN
// Izin Siswa: Alpha / Sakit / Keperluan Lain
// ==========================================

type PermitStatus string
type PermitType string

const (
	PermitPending  PermitStatus = "PENDING"
	PermitApproved PermitStatus = "APPROVED"
	PermitRejected PermitStatus = "REJECTED"
)

const (
	PermitSick       PermitType = "SICK"
	PermitPermission PermitType = "PERMISSION"
	PermitAlpha      PermitType = "ALPHA"
)

// StudentPermit represents an absence/leave request submitted by a student.
type StudentPermit struct {
	ID          uuid.UUID    `json:"id"`
	TenantID    uuid.UUID    `json:"tenant_id"`
	StudentID   uuid.UUID    `json:"student_id"`
	StudentName string       `json:"student_name,omitempty"`
	Type        PermitType   `json:"type"`
	Reason      string       `json:"reason"`
	StartDate   time.Time    `json:"start_date"`
	EndDate     time.Time    `json:"end_date"`
	Status      PermitStatus `json:"status"`
	ReviewedBy  *uuid.UUID   `json:"reviewed_by,omitempty"`
	ReviewNote  string       `json:"review_note,omitempty"`
	AttachmentURL string     `json:"attachment_url,omitempty"`
	CreatedAt   time.Time    `json:"created_at"`
	UpdatedAt   time.Time    `json:"updated_at"`
}

// PermitRepository defines data access for student permits.
type PermitRepository interface {
	Create(ctx context.Context, permit *StudentPermit) error
	GetByID(ctx context.Context, id uuid.UUID) (*StudentPermit, error)
	GetByStudent(ctx context.Context, tenantID, studentID uuid.UUID) ([]*StudentPermit, error)
	GetPending(ctx context.Context, tenantID uuid.UUID) ([]*StudentPermit, error)
	UpdateStatus(ctx context.Context, id uuid.UUID, status PermitStatus, reviewedBy uuid.UUID, note string) error
}

// PermitUsecase defines business logic for student permits.
type PermitUsecase interface {
	SubmitPermit(ctx context.Context, permit *StudentPermit) error
	GetMyPermits(ctx context.Context, tenantID, studentID uuid.UUID) ([]*StudentPermit, error)
	GetPendingPermits(ctx context.Context, tenantID uuid.UUID) ([]*StudentPermit, error)
	ReviewPermit(ctx context.Context, id, reviewerID uuid.UUID, status PermitStatus, note string) error
}

// ==========================================
// COUNSELING (BK) DOMAIN
// Bimbingan Konseling
// ==========================================

type CounselingStatus string

const (
	CounselingRequested CounselingStatus = "REQUESTED"
	CounselingScheduled CounselingStatus = "SCHEDULED"
	CounselingDone      CounselingStatus = "DONE"
	CounselingCancelled CounselingStatus = "CANCELLED"
)

// CounselingSession represents a BK session request.
type CounselingSession struct {
	ID              uuid.UUID        `json:"id"`
	TenantID        uuid.UUID        `json:"tenant_id"`
	StudentID       uuid.UUID        `json:"student_id"`
	StudentName     string           `json:"student_name,omitempty"`
	CounselorID     *uuid.UUID       `json:"counselor_id,omitempty"`
	CounselorName   string           `json:"counselor_name,omitempty"`
	Topic           string           `json:"topic"`
	Description     string           `json:"description"`
	PreferredDate   time.Time        `json:"preferred_date"`
	ScheduledAt     *time.Time       `json:"scheduled_at,omitempty"`
	Status          CounselingStatus `json:"status"`
	Notes           string           `json:"notes,omitempty"`
	CreatedAt       time.Time        `json:"created_at"`
}

// CounselingRepository defines data access for BK sessions.
type CounselingRepository interface {
	Create(ctx context.Context, session *CounselingSession) error
	GetByStudent(ctx context.Context, tenantID, studentID uuid.UUID) ([]*CounselingSession, error)
	GetAll(ctx context.Context, tenantID uuid.UUID) ([]*CounselingSession, error)
	UpdateStatus(ctx context.Context, id uuid.UUID, status CounselingStatus, counselorID uuid.UUID, scheduledAt *time.Time, notes string) error
}

// CounselingUsecase defines business logic for BK sessions.
type CounselingUsecase interface {
	BookSession(ctx context.Context, session *CounselingSession) error
	GetMySessions(ctx context.Context, tenantID, studentID uuid.UUID) ([]*CounselingSession, error)
	GetAllSessions(ctx context.Context, tenantID uuid.UUID) ([]*CounselingSession, error)
	ScheduleSession(ctx context.Context, id, counselorID uuid.UUID, scheduledAt time.Time, notes string) error
}

// ==========================================
// EXTRACURRICULAR DOMAIN
// ==========================================

type ExtracurricularStatus string

const (
	ExtraActive   ExtracurricularStatus = "ACTIVE"
	ExtraInactive ExtracurricularStatus = "INACTIVE"
)

type RegistrationStatus string

const (
	RegPending  RegistrationStatus = "PENDING"
	RegApproved RegistrationStatus = "APPROVED"
	RegRejected RegistrationStatus = "REJECTED"
)

// Extracurricular represents a club/activity offered by the school.
type Extracurricular struct {
	ID          uuid.UUID             `json:"id"`
	TenantID    uuid.UUID             `json:"tenant_id"`
	Name        string                `json:"name"`
	Description string                `json:"description"`
	CoachName   string                `json:"coach_name"`
	Schedule    string                `json:"schedule"` // e.g. "Senin & Rabu, 15:00-17:00"
	MaxMembers  int                   `json:"max_members"`
	TotalMember int                   `json:"total_member"`
	Status      ExtracurricularStatus `json:"status"`
	ImageURL    string                `json:"image_url,omitempty"`
	CreatedAt   time.Time             `json:"created_at"`
}

// ExtracurricularRegistration represents a student's registration request.
type ExtracurricularRegistration struct {
	ID               uuid.UUID          `json:"id"`
	TenantID         uuid.UUID          `json:"tenant_id"`
	StudentID        uuid.UUID          `json:"student_id"`
	StudentName      string             `json:"student_name,omitempty"`
	ExtracurricularID uuid.UUID         `json:"extracurricular_id"`
	ExtracurricularName string          `json:"extracurricular_name,omitempty"`
	Status           RegistrationStatus `json:"status"`
	RegisteredAt     time.Time          `json:"registered_at"`
}

// ExtracurricularRepository defines data access for extracurricular.
type ExtracurricularRepository interface {
	GetAll(ctx context.Context, tenantID uuid.UUID) ([]*Extracurricular, error)
	GetByID(ctx context.Context, id uuid.UUID) (*Extracurricular, error)
	Create(ctx context.Context, extra *Extracurricular) error

	// Registrations
	Register(ctx context.Context, reg *ExtracurricularRegistration) error
	GetMyRegistrations(ctx context.Context, tenantID, studentID uuid.UUID) ([]*ExtracurricularRegistration, error)
	GetRegistrationsByExtra(ctx context.Context, extraID uuid.UUID) ([]*ExtracurricularRegistration, error)
	UpdateRegistrationStatus(ctx context.Context, regID uuid.UUID, status RegistrationStatus) error
}

// ExtracurricularUsecase defines business logic for extracurricular.
type ExtracurricularUsecase interface {
	GetAll(ctx context.Context, tenantID uuid.UUID) ([]*Extracurricular, error)
	Create(ctx context.Context, extra *Extracurricular) error

	// Student self-registration
	Register(ctx context.Context, tenantID, studentID, extraID uuid.UUID) error
	GetMyRegistrations(ctx context.Context, tenantID, studentID uuid.UUID) ([]*ExtracurricularRegistration, error)

	// Admin management
	ApproveRegistration(ctx context.Context, regID uuid.UUID) error
	RejectRegistration(ctx context.Context, regID uuid.UUID) error
}
