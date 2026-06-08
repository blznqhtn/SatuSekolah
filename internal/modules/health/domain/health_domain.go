package domain

import (
	"context"
	"time"

	"github.com/google/uuid"
)

// ==========================================
// HEALTH DOMAIN & MODELS
// ==========================================

type HealthSetting struct {
	TenantID          uuid.UUID `json:"tenant_id"`
	HealthAdminUserID uuid.UUID `json:"health_admin_user_id"`
	CreatedAt         time.Time `json:"created_at"`
}

type HealthRecord struct {
	ID             uuid.UUID `json:"id"`
	TenantID       uuid.UUID `json:"tenant_id"`
	UserID         uuid.UUID `json:"user_id"`
	RecordType     string    `json:"record_type"` // e.g., "GENERAL", "CHECKUP"
	Date           time.Time `json:"date"`
	Height         float64   `json:"height"`
	Weight         float64   `json:"weight"`
	Hearing        string    `json:"hearing"`
	Vision         string    `json:"vision"`
	Dental         string    `json:"dental"`
	Hemoglobin     float64   `json:"hemoglobin"`
	Notes          string    `json:"notes"`
	AIRecommendation string  `json:"ai_recommendation"`
	CreatedAt      time.Time `json:"created_at"`
	UpdatedAt      time.Time `json:"updated_at"`
	UpdatedBy      uuid.UUID `json:"updated_by"`
}

type CycleStatus string

const (
	CycleOngoing        CycleStatus = "ONGOING"
	CycleCompleted      CycleStatus = "COMPLETED"
	CycleBlockedOverdue CycleStatus = "BLOCKED_OVERDUE"
)

type MenstrualCycle struct {
	ID         uuid.UUID   `json:"id"`
	TenantID   uuid.UUID   `json:"tenant_id"`
	UserID     uuid.UUID   `json:"user_id"`
	StartDate  time.Time   `json:"start_date"`
	EndDate    *time.Time  `json:"end_date"`
	Symptoms   string      `json:"symptoms"`
	AIAdvice   string      `json:"ai_advice"`
	Status     CycleStatus `json:"status"`
	CreatedAt  time.Time   `json:"created_at"`
	UpdatedAt  time.Time   `json:"updated_at"`
}

type RibbonStatus string

const (
	RibbonBorrowed RibbonStatus = "BORROWED"
	RibbonReturned RibbonStatus = "RETURNED"
	RibbonOverdue  RibbonStatus = "OVERDUE"
)

type RibbonBorrowing struct {
	ID               uuid.UUID    `json:"id"`
	TenantID         uuid.UUID    `json:"tenant_id"`
	UserID           uuid.UUID    `json:"user_id"`
	CycleID          uuid.UUID    `json:"cycle_id"`
	BorrowedAt       time.Time    `json:"borrowed_at"`
	ExpectedReturnAt time.Time    `json:"expected_return_at"`
	ReturnedAt       *time.Time   `json:"returned_at"`
	Status           RibbonStatus `json:"status"`
	SanctionNotes    string       `json:"sanction_notes"`
	HandledBy        *uuid.UUID   `json:"handled_by"` // Admin ID who returned it
}

// ==========================================
// INTERFACES
// ==========================================

type HealthRepository interface {
	GetSetting(ctx context.Context, tenantID uuid.UUID) (*HealthSetting, error)
	UpsertSetting(ctx context.Context, setting *HealthSetting) error

	CreateRecord(ctx context.Context, record *HealthRecord) error
	GetRecordsByUser(ctx context.Context, userID uuid.UUID) ([]*HealthRecord, error)

	CreateCycle(ctx context.Context, cycle *MenstrualCycle) error
	GetActiveCycle(ctx context.Context, userID uuid.UUID) (*MenstrualCycle, error)
	UpdateCycle(ctx context.Context, cycle *MenstrualCycle) error

	CreateRibbon(ctx context.Context, ribbon *RibbonBorrowing) error
	GetActiveRibbon(ctx context.Context, userID uuid.UUID) (*RibbonBorrowing, error)
	UpdateRibbon(ctx context.Context, ribbon *RibbonBorrowing) error
	
	GetOverdueCyclesAndRibbons(ctx context.Context, tenantID uuid.UUID) ([]*MenstrualCycle, []*RibbonBorrowing, error)
}

type HealthUsecase interface {
	ConfigureSetting(ctx context.Context, setting *HealthSetting, requesterID uuid.UUID) error
	GetSetting(ctx context.Context, tenantID uuid.UUID) (*HealthSetting, error)

	AddHealthRecord(ctx context.Context, record *HealthRecord, adminID uuid.UUID) error
	GetMyHealthRecords(ctx context.Context, userID uuid.UUID) ([]*HealthRecord, error)

	StartMenstrualCycle(ctx context.Context, tenantID, userID uuid.UUID, symptoms string) (*MenstrualCycle, error)
	StopMenstrualCycle(ctx context.Context, userID uuid.UUID) error
	
	BorrowRibbon(ctx context.Context, tenantID, userID uuid.UUID) (*RibbonBorrowing, error)

	// Admin overrides
	GetOverdueWatchlist(ctx context.Context, tenantID, adminID uuid.UUID) ([]*MenstrualCycle, []*RibbonBorrowing, error)
	ForceStopCycleAndRibbon(ctx context.Context, cycleID uuid.UUID, adminID uuid.UUID, sanctionNotes string) error
}
