package repositories

import (
	"context"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/presence/entities"
)

type AttendanceRepository interface {
	Save(ctx context.Context, att *entities.Attendance) error
	Update(ctx context.Context, att *entities.Attendance) error
	FindTodayAttendance(ctx context.Context, userID string) (*entities.Attendance, error)
}

type LeaveRequestRepository interface {
	Save(ctx context.Context, lr *entities.LeaveRequest) error
	Update(ctx context.Context, lr *entities.LeaveRequest) error
}

type LeaveApprovalRepository interface {
	Save(ctx context.Context, la *entities.LeaveApproval) error
}
