package domain

import (
	"context"
	"time"

	"github.com/google/uuid"
)

type PkgPeriod struct {
	ID        uuid.UUID `json:"id"`
	TenantID  uuid.UUID `json:"tenant_id"`
	Name      string    `json:"name"`
	StartDate time.Time `json:"start_date"`
	EndDate   time.Time `json:"end_date"`
	IsActive  bool      `json:"is_active"`
	CreatedAt time.Time `json:"created_at"`
}

type PkgIndicator struct {
	ID                 uuid.UUID `json:"id"`
	TenantID           uuid.UUID `json:"tenant_id"`
	Name               string    `json:"name"`
	Description        string    `json:"description"`
	Weight             float64   `json:"weight"`
	IsApplicableToAll  bool      `json:"is_applicable_to_all"`
	CreatedAt          time.Time `json:"created_at"`
}

type PkgSubmission struct {
	ID           uuid.UUID `json:"id"`
	PeriodID     uuid.UUID `json:"period_id"`
	IndicatorID  uuid.UUID `json:"indicator_id"`
	StaffID    uuid.UUID `json:"staff_id"`
	DocumentURL  string    `json:"document_url"`
	Description  string    `json:"description"`
	SubmittedAt  time.Time `json:"submitted_at"`
}

type PkgEvaluation struct {
	ID           uuid.UUID `json:"id"`
	SubmissionID uuid.UUID `json:"submission_id"`
	EvaluatorID  uuid.UUID `json:"evaluator_id"`
	Score        float64   `json:"score"`
	Comments     string    `json:"comments"`
	EvaluatedAt  time.Time `json:"evaluated_at"`
}

// FairAverageResult represents the output of the fair averaging calculation
type FairAverageResult struct {
	StaffID       uuid.UUID `json:"staff_id"`
	PeriodID        uuid.UUID `json:"period_id"`
	TotalWeight     float64   `json:"total_weight_applicable"`
	WeightedScore   float64   `json:"weighted_score"`
	FinalAverage    float64   `json:"final_average"`
	TotalSubmissions int      `json:"total_submissions"`
}

type PkgRepository interface {
	ExecTx(ctx context.Context, fn func(repo PkgRepository) error) error

	// Periods
	CreatePeriod(ctx context.Context, period *PkgPeriod) error
	GetPeriods(ctx context.Context, tenantID uuid.UUID) ([]*PkgPeriod, error)
	GetActivePeriod(ctx context.Context, tenantID uuid.UUID) (*PkgPeriod, error)

	// Indicators
	CreateIndicator(ctx context.Context, indicator *PkgIndicator) error
	GetIndicators(ctx context.Context, tenantID uuid.UUID) ([]*PkgIndicator, error)

	// Submissions
	CreateSubmission(ctx context.Context, submission *PkgSubmission) error
	GetSubmissionsByTeacherAndPeriod(ctx context.Context, StaffID, periodID uuid.UUID) ([]*PkgSubmission, error)
	GetSubmissionByID(ctx context.Context, submissionID uuid.UUID) (*PkgSubmission, error)

	// Evaluations
	CreateEvaluation(ctx context.Context, evaluation *PkgEvaluation) error
	GetEvaluationsBySubmission(ctx context.Context, submissionID uuid.UUID) ([]*PkgEvaluation, error)

	// Analytics & Fair Averaging
	GetTeacherFairAverage(ctx context.Context, StaffID, periodID uuid.UUID) (*FairAverageResult, error)
}

type PkgUsecase interface {
	// Admin tasks
	CreatePeriod(ctx context.Context, period *PkgPeriod) error
	CreateIndicator(ctx context.Context, indicator *PkgIndicator) error
	GetIndicators(ctx context.Context, tenantID uuid.UUID) ([]*PkgIndicator, error)

	// Staff tasks
	SubmitDocument(ctx context.Context, submission *PkgSubmission) error
	GetMySubmissions(ctx context.Context, StaffID, periodID uuid.UUID) ([]*PkgSubmission, error)

	// Evaluator (Admin/Principal) tasks
	EvaluateSubmission(ctx context.Context, evaluation *PkgEvaluation) error

	// Analytics
	CalculateFairAverage(ctx context.Context, StaffID, periodID uuid.UUID) (*FairAverageResult, error)

	// Query helpers used by other modules (e.g. PKL → E-Kinerja)
	GetActivePeriod(ctx context.Context, tenantID uuid.UUID) (*PkgPeriod, error)
}
