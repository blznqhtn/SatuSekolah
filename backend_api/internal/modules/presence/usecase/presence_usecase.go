package usecase

import (
	"context"
	"time"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/presence/domain"
)

type presenceUsecase struct {
	repo domain.PresenceRepository
}

func NewPresenceUsecase(repo domain.PresenceRepository) domain.PresenceUsecase {
	return &presenceUsecase{repo: repo}
}

func (u *presenceUsecase) GetSummary(ctx context.Context, tenantID, studentID uuid.UUID) (*domain.AttendanceSummary, error) {
	return u.repo.GetSummary(ctx, tenantID, studentID)
}

func (u *presenceUsecase) GetWeekly(ctx context.Context, tenantID, studentID uuid.UUID, date time.Time) ([]*domain.WeeklyAttendance, error) {
	// Find the start of the week (Monday)
	weekday := int(date.Weekday())
	if weekday == 0 {
		weekday = 7 // Make Sunday 7 instead of 0 for easier calculation
	}
	startDate := date.AddDate(0, 0, -weekday+1)
	endDate := startDate.AddDate(0, 0, 6)

	return u.repo.GetWeekly(ctx, tenantID, studentID, startDate, endDate)
}

func (u *presenceUsecase) GetHistory(ctx context.Context, tenantID, studentID uuid.UUID) ([]*domain.ScheduleAttendance, error) {
	return u.repo.GetHistory(ctx, tenantID, studentID)
}
