package usecase

import (
	"context"
	"errors"
	"time"

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

func (u *academicUsecase) GetStudentSchedules(ctx context.Context, tenantID, studentID uuid.UUID, dayOfWeek int) ([]*domain.ScheduleResponseDTO, error) {
	// 1. Get Class ID for student
	classIDPtr, err := u.repo.GetClassIDByStudentID(ctx, studentID)
	if err != nil {
		return nil, err
	}
	if classIDPtr == nil {
		return nil, errors.New("student does not have a class assigned")
	}

	// 2. Get base schedules
	schedules, err := u.repo.GetSchedulesByClassAndDay(ctx, tenantID, *classIDPtr, dayOfWeek)
	if err != nil {
		return nil, err
	}

	// 3. Get schedule changes for the upcoming date that matches dayOfWeek
	// For simplicity, let's just find the next date that corresponds to dayOfWeek
	now := time.Now()
	daysUntilTarget := (dayOfWeek - int(now.Weekday())) % 7
	if daysUntilTarget < 0 {
		daysUntilTarget += 7
	}
	// If today is the target day, we check today's changes
	targetDate := now.AddDate(0, 0, daysUntilTarget)

	changes, err := u.repo.GetScheduleChangesByDate(ctx, tenantID, *classIDPtr, targetDate)
	if err != nil {
		// Log error, but don't fail the whole request
		return schedules, nil
	}

	// 4. Apply changes to schedules
	changeMap := make(map[uuid.UUID]*domain.ScheduleChange)
	for _, ch := range changes {
		changeMap[ch.ScheduleID] = ch
	}

	for _, s := range schedules {
		if ch, exists := changeMap[s.ScheduleID]; exists {
			s.IsChanged = true
			if ch.NewStartTime != "" {
				s.StartTime = ch.NewStartTime
				if len(s.StartTime) > 5 {
					s.StartTime = s.StartTime[:5]
				}
			}
			if ch.NewEndTime != "" {
				s.EndTime = ch.NewEndTime
				if len(s.EndTime) > 5 {
					s.EndTime = s.EndTime[:5]
				}
			}
			if ch.NewRoom != "" {
				s.Room = ch.NewRoom
			}
			if ch.Notes != "" {
				s.ChangeNotes = ch.Notes
			}
			if ch.NewStaffID != nil {
				// We'd ideally join users to get the new staff name, but for now we'll just indicate it changed
				s.StaffName = "Guru Pengganti" 
			}
		}
	}

	return schedules, nil
}
