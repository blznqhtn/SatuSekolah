package domain

import (
	"context"
	"time"

	"github.com/google/uuid"
)

type EvaluationPeriod struct {
	ID        uuid.UUID `json:"id"`
	TenantID  uuid.UUID `json:"tenant_id"`
	Name      string    `json:"name"`
	StartDate time.Time `json:"start_date"`
	EndDate   time.Time `json:"end_date"`
	IsActive  bool      `json:"is_active"`
}

type EvaluationCategory struct {
	ID       uuid.UUID `json:"id"`
	TenantID uuid.UUID `json:"tenant_id"`
	Name     string    `json:"name"`
	Weight   float64   `json:"weight"`
}

type EvaluationSubmission struct {
	ID          uuid.UUID `json:"id"`
	TenantID    uuid.UUID `json:"tenant_id"`
	PeriodID    uuid.UUID `json:"period_id"`
	TeacherID   uuid.UUID `json:"teacher_id"`
	EvaluatorID uuid.UUID `json:"evaluator_id"`
}

type CategoryScore struct {
	CategoryID uuid.UUID `json:"category_id"`
	Score      float64   `json:"score"`
}

type SubmitEvaluationRequest struct {
	TeacherID     uuid.UUID       `json:"teacher_id"`
	PeriodID      uuid.UUID       `json:"period_id"`
	Scores        []CategoryScore `json:"scores"`
	Advantages    string          `json:"advantages"`
	Disadvantages string          `json:"disadvantages"`
	Suggestions   string          `json:"suggestions"`
}

type TeacherEligibleDTO struct {
	ID        uuid.UUID `json:"id"`
	Name      string    `json:"name"`
	Course    string    `json:"course"`
	IsGraded  bool      `json:"is_graded"`
}

type EvaluationResultDTO struct {
	TeacherID       uuid.UUID                 `json:"teacher_id"`
	TeacherName     string                    `json:"teacher_name"`
	TotalEvaluators int                       `json:"total_evaluators"`
	AverageScore    float64                   `json:"average_score"`
	CategoryAverages map[uuid.UUID]float64    `json:"category_averages"`
	Comments        []EvaluationCommentResult `json:"comments"`
}

type EvaluationCommentResult struct {
	Advantages    string `json:"advantages"`
	Disadvantages string `json:"disadvantages"`
	Suggestions   string `json:"suggestions"`
}

type EvaluationRepository interface {
	GetActivePeriod(ctx context.Context, tenantID uuid.UUID) (*EvaluationPeriod, error)
	GetCategories(ctx context.Context, tenantID uuid.UUID) ([]*EvaluationCategory, error)
	GetEligibleTeachers(ctx context.Context, tenantID, studentID, periodID uuid.UUID) ([]*TeacherEligibleDTO, error)
	
	HasSubmitted(ctx context.Context, periodID, teacherID, evaluatorID uuid.UUID) (bool, error)
	
	SaveSubmission(ctx context.Context, submission *EvaluationSubmission) error
	SaveScores(ctx context.Context, tenantID, periodID, teacherID uuid.UUID, scores []CategoryScore) error
	SaveComment(ctx context.Context, tenantID, periodID, teacherID uuid.UUID, advantages, disadvantages, suggestions string) error

	GetTeacherResults(ctx context.Context, tenantID, periodID, teacherID uuid.UUID) (*EvaluationResultDTO, error)
}

type EvaluationUsecase interface {
	GetActivePeriod(ctx context.Context, tenantID uuid.UUID) (*EvaluationPeriod, error)
	GetCategories(ctx context.Context, tenantID uuid.UUID) ([]*EvaluationCategory, error)
	GetEligibleTeachers(ctx context.Context, tenantID, studentID uuid.UUID) ([]*TeacherEligibleDTO, error)
	
	SubmitEvaluation(ctx context.Context, tenantID, evaluatorID uuid.UUID, req *SubmitEvaluationRequest) error
	GetTeacherResults(ctx context.Context, tenantID, periodID, teacherID uuid.UUID) (*EvaluationResultDTO, error)
}
