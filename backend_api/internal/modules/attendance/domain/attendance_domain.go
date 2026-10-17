package domain

import (
	"context"
	"time"

	"github.com/google/uuid"
)

type AttendanceStatus string

const (
	StatusPresent AttendanceStatus = "PRESENT"
	StatusLate    AttendanceStatus = "LATE"
	StatusAbsent  AttendanceStatus = "ABSENT"
	StatusExcused AttendanceStatus = "EXCUSED"
)

type AttendanceMethod string

const (
	MethodRFID        AttendanceMethod = "RFID"
	MethodFace        AttendanceMethod = "FACE"
	MethodFingerprint AttendanceMethod = "FINGERPRINT"
	MethodSystem      AttendanceMethod = "SYSTEM"
)

type AppliesToType string

const (
	AppliesToStudent AppliesToType = "STUDENT"
	AppliesToStaff   AppliesToType = "STAFF"
	AppliesToAll     AppliesToType = "ALL"
)

type AttendanceSetting struct {
	TenantID               uuid.UUID `json:"tenant_id"`
	AttendanceAdminStaffID *uuid.UUID `json:"attendance_admin_staff_id"`
	HolidayManagerRoleID   *uuid.UUID `json:"holiday_manager_role_id"`
	CheckInTime            string    `json:"check_in_time"`
	CheckOutTime           string    `json:"check_out_time"`
	ToleranceMinutes       int       `json:"tolerance_minutes"`
	AllowRFID              bool      `json:"allow_rfid"`
	AllowFingerprint       bool      `json:"allow_fingerprint"`
	AllowFace              bool      `json:"allow_face"`
	FaceMatchThreshold     float64   `json:"face_match_threshold"`
	UpdatedAt              *time.Time `json:"updated_at"`
	UpdatedBy              *uuid.UUID `json:"updated_by"`
}

type Holiday struct {
	ID        uuid.UUID     `json:"id"`
	TenantID  uuid.UUID     `json:"tenant_id"`
	Name      string        `json:"name"`
	Date      time.Time     `json:"date"`
	AppliesTo AppliesToType `json:"applies_to"`
	CreatedAt time.Time     `json:"created_at"`
	CreatedBy *uuid.UUID    `json:"created_by"`
}

type Activity struct {
	ID                      uuid.UUID `json:"id"`
	TenantID                uuid.UUID `json:"tenant_id"`
	Name                    string    `json:"name"`
	IsMandatory             bool      `json:"is_mandatory"`
	StartTime               time.Time `json:"start_time"`
	EndTime                 time.Time `json:"end_time"`
	RequiresCheckout        bool      `json:"requires_checkout"`
	ReplacesDailyAttendance bool      `json:"replaces_daily_attendance"`
	CreatedBy               *uuid.UUID `json:"created_by"`
	CreatedAt               time.Time `json:"created_at"`
}

type Attendance struct {
	ID         uuid.UUID        `json:"id"`
	TenantID   uuid.UUID        `json:"tenant_id"`
	UserID     uuid.UUID        `json:"user_id"`
	Type       string           `json:"type"` // DAILY or ACTIVITY_REPLACEMENT
	Method     AttendanceMethod `json:"method"`
	CheckInAt  *time.Time       `json:"check_in_at"`
	CheckOutAt *time.Time       `json:"check_out_at"`
	Status     AttendanceStatus `json:"status"`
	Notes      *string          `json:"notes"`
}

type ActivityAttendance struct {
	ID         uuid.UUID        `json:"id"`
	ActivityID uuid.UUID        `json:"activity_id"`
	UserID     uuid.UUID        `json:"user_id"`
	CheckInAt  *time.Time       `json:"check_in_at"`
	CheckOutAt *time.Time       `json:"check_out_at"`
	Status     AttendanceStatus `json:"status"`
	CreatedAt  time.Time        `json:"created_at"`
}

type PresenceRequest struct {
	TenantID   uuid.UUID        `json:"tenant_id"`
	Method     AttendanceMethod `json:"method"`
	Identifier string           `json:"identifier"` // RFID token, Face image base64, or Fingerprint hash
}

type FaceRegistrationRequest struct {
	Images []string `json:"images"` // Base64 encoded images (expect 6)
}

type AttendanceRepository interface {
	GetSetting(ctx context.Context, tenantID uuid.UUID) (*AttendanceSetting, error)
	GetHoliday(ctx context.Context, tenantID uuid.UUID, date time.Time) (*Holiday, error)
	
	// Activity
	GetActiveActivities(ctx context.Context, tenantID uuid.UUID, currentTime time.Time) ([]*Activity, error)
	IsUserTargetedForActivity(ctx context.Context, activityID uuid.UUID, userID, classID, roleID uuid.UUID) (bool, error)
	
	// Attendances
	GetTodayDailyAttendance(ctx context.Context, tenantID, userID uuid.UUID) (*Attendance, error)
	GetTodayActivityAttendance(ctx context.Context, activityID, userID uuid.UUID) (*ActivityAttendance, error)
	
	CreateDailyAttendance(ctx context.Context, att *Attendance) error
	UpdateDailyAttendance(ctx context.Context, att *Attendance) error
	
	CreateActivityAttendance(ctx context.Context, att *ActivityAttendance) error
	UpdateActivityAttendance(ctx context.Context, att *ActivityAttendance) error
	
	// Lates
	CreateLateRecord(ctx context.Context, attendanceID uuid.UUID, reason string) error
	
	// User
	UpdateUserFaceID(ctx context.Context, userID uuid.UUID, faceID string) error
	GetUserByIdentifier(ctx context.Context, tenantID uuid.UUID, method AttendanceMethod, identifier string) (*uuid.UUID, *uuid.UUID, *uuid.UUID, error) // Returns UserID, ClassID, RoleID
}

type AttendanceUsecase interface {
	ProcessPresence(ctx context.Context, req *PresenceRequest) (interface{}, error)
	RegisterFace(ctx context.Context, userID uuid.UUID, req *FaceRegistrationRequest) (string, error)
}
