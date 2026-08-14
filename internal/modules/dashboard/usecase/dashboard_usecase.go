package usecase

import (
	"context"
	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/dashboard/domain"
)

type dashboardUsecase struct {
	repo domain.DashboardRepository
}

func NewDashboardUsecase(repo domain.DashboardRepository) domain.DashboardUsecase {
	return &dashboardUsecase{repo: repo}
}

func (u *dashboardUsecase) GetSummary(ctx context.Context, tenantID, studentID uuid.UUID) (*domain.DashboardSummary, error) {
	info, err := u.repo.GetStudentInfo(ctx, tenantID, studentID)
	if err != nil {
		return nil, err
	}

	att, _ := u.repo.GetAttendancePercentage(ctx, tenantID, studentID)
	score, _ := u.repo.GetAverageScore(ctx, tenantID, studentID)
	pts, _ := u.repo.GetTotalViolationPoints(ctx, tenantID, studentID)

	return &domain.DashboardSummary{
		Student:             info,
		AttendancePercent:   att,
		AverageScore:        score,
		TotalViolationPoints: pts,
	}, nil
}

func (u *dashboardUsecase) GetActivities(ctx context.Context, tenantID, studentID uuid.UUID) ([]*domain.ActivityLog, error) {
	return u.repo.GetActivities(ctx, tenantID, studentID, 10) // fetch last 10
}
