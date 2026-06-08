package domain

import (
	"context"
	"time"

	"github.com/google/uuid"
)

// AppliesToCategory defines who a violation type applies to
type AppliesToCategory string

const (
	AppliesToStudent AppliesToCategory = "STUDENT"
	AppliesToStaff   AppliesToCategory = "STAFF"
	AppliesToAll     AppliesToCategory = "ALL"
)

// SystemViolationTypeIDs are seeded and cannot be deleted
const (
	SystemViolationLateStudent = "vt-001"
	SystemViolationLateStaff   = "vt-002"
)

// ViolationType defines a category of violation with a base point penalty
type ViolationType struct {
	ID              string            `json:"id"`
	TenantID        *uuid.UUID        `json:"tenant_id"` // nil = global system default
	Name            string            `json:"name"`
	Description     *string           `json:"description"`
	Points          int               `json:"points"`
	AppliesTo       AppliesToCategory `json:"applies_to"`
	IsActive        bool              `json:"is_active"`
	IsSystemDefault bool              `json:"is_system_default"`
	CreatedBy       *uuid.UUID        `json:"created_by"`
	CreatedAt       time.Time         `json:"created_at"`
}

// UserViolation is a recorded violation event for a specific user
type UserViolation struct {
	ID              uuid.UUID  `json:"id"`
	TenantID        uuid.UUID  `json:"tenant_id"`
	UserID          uuid.UUID  `json:"user_id"`
	ViolationTypeID string     `json:"violation_type_id"`
	PointsApplied   int        `json:"points_applied"`
	EvidenceURL     *string    `json:"evidence_url"`
	Notes           *string    `json:"notes"`
	RecordedBy      *uuid.UUID `json:"recorded_by"`
	ParentNotified  bool       `json:"parent_notified"`
	CreatedAt       time.Time  `json:"created_at"`
}

// CreateViolationTypeRequest is the payload for staff/admin to add new types
type CreateViolationTypeRequest struct {
	Name        string            `json:"name"`
	Description string            `json:"description"`
	Points      int               `json:"points"`
	AppliesTo   AppliesToCategory `json:"applies_to"`
}

// RecordViolationRequest is the payload for recording a violation on a user.
// Staff selects multiple violation_type_ids; points are summed.
type RecordViolationRequest struct {
	UserID           uuid.UUID `json:"user_id"`
	ViolationTypeIDs []string  `json:"violation_type_ids"` // Multiple types can be selected at once
	EvidenceURL      string    `json:"evidence_url"`
	Notes            string    `json:"notes"`
}

// ViolationRepository defines database operations for the violation module
type ViolationRepository interface {
	// Types
	CreateViolationType(ctx context.Context, vt *ViolationType) error
	GetViolationTypes(ctx context.Context, tenantID uuid.UUID) ([]*ViolationType, error)
	GetViolationTypeByID(ctx context.Context, id string) (*ViolationType, error)
	ToggleViolationTypeActive(ctx context.Context, id string, isActive bool) error
	DeleteViolationType(ctx context.Context, id string) error // Only allowed if !is_system_default

	// User Records
	CreateUserViolation(ctx context.Context, uv *UserViolation) error
	GetUserViolations(ctx context.Context, tenantID, userID uuid.UUID) ([]*UserViolation, error)
	GetUserTotalPoints(ctx context.Context, tenantID, userID uuid.UUID) (int, error)

	// Used by attendance usecase to auto-record system violations
	RecordSystemLateViolation(ctx context.Context, tenantID, userID uuid.UUID, category AppliesToCategory) error

	// Parent notification helper
	GetParentIDByUserID(ctx context.Context, userID uuid.UUID) (*uuid.UUID, error)
}

// ViolationUsecase defines the business logic for violation management
type ViolationUsecase interface {
	CreateViolationType(ctx context.Context, tenantID, staffID uuid.UUID, req *CreateViolationTypeRequest) (*ViolationType, error)
	GetViolationTypes(ctx context.Context, tenantID uuid.UUID) ([]*ViolationType, error)
	ToggleViolationType(ctx context.Context, id string, isActive bool) error
	DeleteViolationType(ctx context.Context, id string) error
	RecordViolation(ctx context.Context, tenantID, staffID uuid.UUID, req *RecordViolationRequest) ([]*UserViolation, error)
	GetUserViolationHistory(ctx context.Context, tenantID, userID uuid.UUID) ([]*UserViolation, int, error)
}
