package services

import (
	"context"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/presence/entities"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/presence/requests"
)

type AttendanceService interface {
	CheckIn(ctx context.Context, req *requests.CheckInRequest) (*entities.Attendance, error)
	CheckOut(ctx context.Context, req *requests.CheckOutRequest) (*entities.Attendance, error)
	RequestLeave(ctx context.Context, req *requests.LeaveRequest) (*entities.LeaveRequest, error)
	ApproveLeave(ctx context.Context, req *requests.ApproveLeaveRequest) (*entities.LeaveRequest, error)
}
