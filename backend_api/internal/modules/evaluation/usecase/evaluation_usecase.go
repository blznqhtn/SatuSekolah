package usecase

import (
	"context"
	"errors"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/evaluation/domain"
)

type evaluationUsecase struct {
	repo domain.EvaluationRepository
}

func NewEvaluationUsecase(repo domain.EvaluationRepository) domain.EvaluationUsecase {
	return &evaluationUsecase{repo: repo}
}

func (u *evaluationUsecase) GetActivePeriod(ctx context.Context, tenantID uuid.UUID) (*domain.EvaluationPeriod, error) {
	return u.repo.GetActivePeriod(ctx, tenantID)
}

func (u *evaluationUsecase) GetCategories(ctx context.Context, tenantID uuid.UUID) ([]*domain.EvaluationCategory, error) {
	return u.repo.GetCategories(ctx, tenantID)
}

func (u *evaluationUsecase) GetEligibleTeachers(ctx context.Context, tenantID, studentID uuid.UUID) ([]*domain.TeacherEligibleDTO, error) {
	period, err := u.repo.GetActivePeriod(ctx, tenantID)
	if err != nil {
		return nil, err
	}
	if period == nil {
		return []*domain.TeacherEligibleDTO{}, nil // No active period, no eligible teachers
	}
	return u.repo.GetEligibleTeachers(ctx, tenantID, studentID, period.ID)
}

func (u *evaluationUsecase) SubmitEvaluation(ctx context.Context, tenantID, evaluatorID uuid.UUID, req *domain.SubmitEvaluationRequest) error {
	// Verify period is active
	period, err := u.repo.GetActivePeriod(ctx, tenantID)
	if err != nil {
		return err
	}
	if period == nil || period.ID != req.PeriodID {
		return errors.New("evaluation period is not active or invalid")
	}

	// Verify duplicate submission
	hasSub, err := u.repo.HasSubmitted(ctx, req.PeriodID, req.TeacherID, evaluatorID)
	if err != nil {
		return err
	}
	if hasSub {
		return errors.New("you have already evaluated this teacher in the current period")
	}

	// 1. Record Submission (links evaluator to teacher and period, prevents duplicate)
	sub := &domain.EvaluationSubmission{
		ID:          uuid.New(),
		TenantID:    tenantID,
		PeriodID:    req.PeriodID,
		TeacherID:   req.TeacherID,
		EvaluatorID: evaluatorID,
	}
	if err := u.repo.SaveSubmission(ctx, sub); err != nil {
		return err
	}

	// 2. Save Scores (Completely anonymous, no link to submission ID or evaluator ID)
	if len(req.Scores) > 0 {
		if err := u.repo.SaveScores(ctx, tenantID, req.PeriodID, req.TeacherID, req.Scores); err != nil {
			return err
		}
	}

	// 3. Save Comments (Completely anonymous)
	if req.Advantages != "" || req.Disadvantages != "" || req.Suggestions != "" {
		if err := u.repo.SaveComment(ctx, tenantID, req.PeriodID, req.TeacherID, req.Advantages, req.Disadvantages, req.Suggestions); err != nil {
			return err
		}
	}

	return nil
}

func (u *evaluationUsecase) GetTeacherResults(ctx context.Context, tenantID, periodID, teacherID uuid.UUID) (*domain.EvaluationResultDTO, error) {
	return u.repo.GetTeacherResults(ctx, tenantID, periodID, teacherID)
}
