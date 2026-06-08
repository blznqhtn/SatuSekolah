package usecase

import (
	"context"
	"errors"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/academic/domain"
)

type academicUsecase struct {
	repo domain.AcademicRepository
}

func NewAcademicUsecase(repo domain.AcademicRepository) domain.AcademicUsecase {
	return &academicUsecase{repo: repo}
}

func (u *academicUsecase) CreateCourse(ctx context.Context, course *domain.Course) error {
	if course.Name == "" {
		return errors.New("course name is required")
	}
	return u.repo.CreateCourse(ctx, course)
}

func (u *academicUsecase) GetCourses(ctx context.Context, tenantID uuid.UUID) ([]*domain.Course, error) {
	return u.repo.GetCourses(ctx, tenantID)
}

func (u *academicUsecase) CreateModule(ctx context.Context, module *domain.CourseModule) error {
	if module.Title == "" {
		return errors.New("module title is required")
	}
	return u.repo.CreateModule(ctx, module)
}

func (u *academicUsecase) GetModulesByCourse(ctx context.Context, courseID uuid.UUID) ([]*domain.CourseModule, error) {
	return u.repo.GetModulesByCourse(ctx, courseID)
}

func (u *academicUsecase) SubmitWork(ctx context.Context, sub *domain.Submission) error {
	if sub.FileURL == "" {
		return errors.New("file_url is required")
	}
	return u.repo.CreateSubmission(ctx, sub)
}

func (u *academicUsecase) GetSubmissionsByModule(ctx context.Context, moduleID uuid.UUID) ([]*domain.Submission, error) {
	return u.repo.GetSubmissionsByModule(ctx, moduleID)
}

func (u *academicUsecase) GradeSubmission(ctx context.Context, submissionID uuid.UUID, score float64, gradedBy uuid.UUID) error {
	if score < 0 || score > 100 {
		return errors.New("score must be between 0 and 100")
	}
	return u.repo.GradeSubmission(ctx, submissionID, score, gradedBy)
}

func (u *academicUsecase) AssignTarget(ctx context.Context, target *domain.AssignmentTarget) error {
	if target.SourceID == uuid.Nil || target.TargetID == uuid.Nil {
		return errors.New("source_id and target_id are required")
	}
	return u.repo.CreateAssignmentTarget(ctx, target)
}

func (u *academicUsecase) GetTargetsForSource(ctx context.Context, sourceType domain.SourceType, sourceID uuid.UUID) ([]*domain.AssignmentTarget, error) {
	return u.repo.GetTargetsForSource(ctx, sourceType, sourceID)
}
