package usecase

import (
	"context"
	"errors"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/pkg/domain"
)

type pkgUsecase struct {
	repo domain.PkgRepository
}

func NewPkgUsecase(repo domain.PkgRepository) domain.PkgUsecase {
	return &pkgUsecase{repo: repo}
}

func (u *pkgUsecase) CreatePeriod(ctx context.Context, period *domain.PkgPeriod) error {
	if period.Name == "" {
		return errors.New("period name is required")
	}
	if period.EndDate.Before(period.StartDate) {
		return errors.New("end_date must be after start_date")
	}
	return u.repo.CreatePeriod(ctx, period)
}

func (u *pkgUsecase) CreateIndicator(ctx context.Context, indicator *domain.PkgIndicator) error {
	if indicator.Name == "" {
		return errors.New("indicator name is required")
	}
	if indicator.Weight <= 0 {
		indicator.Weight = 1.0
	}
	return u.repo.CreateIndicator(ctx, indicator)
}

func (u *pkgUsecase) GetIndicators(ctx context.Context, tenantID uuid.UUID) ([]*domain.PkgIndicator, error) {
	return u.repo.GetIndicators(ctx, tenantID)
}

func (u *pkgUsecase) SubmitDocument(ctx context.Context, submission *domain.PkgSubmission) error {
	if submission.DocumentURL == "" {
		return errors.New("document_url is required")
	}
	if submission.PeriodID == uuid.Nil || submission.IndicatorID == uuid.Nil {
		return errors.New("period_id and indicator_id are required")
	}
	return u.repo.CreateSubmission(ctx, submission)
}

func (u *pkgUsecase) GetMySubmissions(ctx context.Context, StaffID, periodID uuid.UUID) ([]*domain.PkgSubmission, error) {
	return u.repo.GetSubmissionsByTeacherAndPeriod(ctx, StaffID, periodID)
}

func (u *pkgUsecase) EvaluateSubmission(ctx context.Context, evaluation *domain.PkgEvaluation) error {
	if evaluation.Score < 0 || evaluation.Score > 100 {
		return errors.New("score must be between 0 and 100")
	}
	sub, err := u.repo.GetSubmissionByID(ctx, evaluation.SubmissionID)
	if err != nil {
		return err
	}
	if sub == nil {
		return errors.New("submission not found")
	}
	return u.repo.CreateEvaluation(ctx, evaluation)
}

// CalculateFairAverage computes the weighted average for a Staff.
// Only indicators where the Staff has actually submitted documents are counted.
// This prevents unfair penalization: a non-homeroom Staff won't be penalized
// for missing "student assignments" or "class documentation" indicators.
func (u *pkgUsecase) CalculateFairAverage(ctx context.Context, StaffID, periodID uuid.UUID) (*domain.FairAverageResult, error) {
	return u.repo.GetTeacherFairAverage(ctx, StaffID, periodID)
}

// GetActivePeriod returns the currently active PKG period for a tenant.
// Exposed for cross-module use (e.g. PKL usecase auto-submitting Hubin monitoring to E-Kinerja).
func (u *pkgUsecase) GetActivePeriod(ctx context.Context, tenantID uuid.UUID) (*domain.PkgPeriod, error) {
	return u.repo.GetActivePeriod(ctx, tenantID)
}
