package requests

import "time"

type CheckInRequest struct {
	TenantID string `json:"tenant_id" validate:"required,uuid"`
	UserID   string `json:"user_id" validate:"required,uuid"`
	Method   string `json:"method" validate:"required"`
}

type CheckOutRequest struct {
	AttendanceID string `json:"attendance_id" validate:"required,uuid"`
	Method       string `json:"method" validate:"required"`
}

type LeaveRequest struct {
	TenantID  string    `json:"tenant_id" validate:"required,uuid"`
	UserID    string    `json:"user_id" validate:"required,uuid"`
	Reason    string    `json:"reason" validate:"required"`
	StartTime time.Time `json:"start_time" validate:"required"`
	EndTime   time.Time `json:"end_time" validate:"required"`
}

type ApproveLeaveRequest struct {
	LeaveRequestID string `json:"leave_request_id" validate:"required,uuid"`
	ApproverRoleID string `json:"approver_role_id" validate:"required,uuid"`
	ApprovedBy     string `json:"approved_by" validate:"required,uuid"`
	Status         string `json:"status" validate:"required"`
}
