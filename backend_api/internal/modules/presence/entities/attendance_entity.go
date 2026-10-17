package entities

import (
	"database/sql"
	"time"

	"github.com/google/uuid"
)

type AttendanceStatus string

const (
	Present AttendanceStatus = "PRESENT"
	Late    AttendanceStatus = "LATE"
	Absent  AttendanceStatus = "ABSENT"
	Excused AttendanceStatus = "EXCUSED"
)

type LeaveStatus string

const (
	Pending  LeaveStatus = "PENDING"
	Approved LeaveStatus = "APPROVED"
	Rejected LeaveStatus = "REJECTED"
)

type AttendanceSetting struct {
	ID               uuid.UUID    `json:"id"`
	TenantID         uuid.UUID    `json:"tenant_id"`
	RoleID           uuid.UUID    `json:"role_id"`
	CheckInTime      string       `json:"check_in_time"`
	CheckOutTime     string       `json:"check_out_time"`
	ToleranceMinutes int          `json:"tolerance_minutes"`
	UpdatedAt        sql.NullTime `json:"updated_at"`
	UpdatedBy        uuid.UUID    `json:"updated_by"`
}

type Attendance struct {
	ID         uuid.UUID        `json:"id"`
	TenantID   uuid.UUID        `json:"tenant_id"`
	UserID     uuid.UUID        `json:"user_id"`
	Type       string           `json:"type"`
	Method     string           `json:"method"`
	CheckInAt  sql.NullTime     `json:"check_in_at"`
	CheckOutAt sql.NullTime     `json:"check_out_at"`
	Status     AttendanceStatus `json:"status"`
}

type LeaveRequest struct {
	ID          uuid.UUID   `json:"id"`
	TenantID    uuid.UUID   `json:"tenant_id"`
	UserID      uuid.UUID   `json:"user_id"`
	Reason      string      `json:"reason"`
	StartTime   time.Time   `json:"start_time"`
	EndTime     time.Time   `json:"end_time"`
	Status      LeaveStatus `json:"status"`
	CurrentTier int         `json:"current_tier"`
	CreatedAt   time.Time   `json:"created_at"`
	UpdatedAt   sql.NullTime `json:"updated_at"`
}

type LeaveApproval struct {
	ID             uuid.UUID   `json:"id"`
	LeaveRequestID uuid.UUID   `json:"leave_request_id"`
	ApproverRoleID uuid.UUID   `json:"approver_role_id"`
	TierLevel      int         `json:"tier_level"`
	Status         LeaveStatus `json:"status"`
	ApprovedBy     uuid.UUID   `json:"approved_by"`
	ApprovedAt     sql.NullTime `json:"approved_at"`
}
