package repository

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/attendance/domain"
)

type attendanceRepository struct {
	db *sql.DB
}

func NewAttendanceRepository(db *sql.DB) domain.AttendanceRepository {
	return &attendanceRepository{db: db}
}

func (r *attendanceRepository) GetSetting(ctx context.Context, tenantID uuid.UUID) (*domain.AttendanceSetting, error) {
	query := `SELECT tenant_id, attendance_admin_staff_id, holiday_manager_role_id, check_in_time, check_out_time, 
                     tolerance_minutes, allow_rfid, allow_fingerprint, allow_face, face_match_threshold 
              FROM attendance_settings WHERE tenant_id = ?`
	row := r.db.QueryRowContext(ctx, query, tenantID)
	
	var set domain.AttendanceSetting
	err := row.Scan(&set.TenantID, &set.AttendanceAdminStaffID, &set.HolidayManagerRoleID, &set.CheckInTime, &set.CheckOutTime,
		&set.ToleranceMinutes, &set.AllowRFID, &set.AllowFingerprint, &set.AllowFace, &set.FaceMatchThreshold)
	if err != nil {
		if err == sql.ErrNoRows {
			// Return default settings
			return &domain.AttendanceSetting{
				TenantID: tenantID,
				ToleranceMinutes: 15,
				AllowRFID: true, AllowFingerprint: true, AllowFace: true,
				FaceMatchThreshold: 80.0,
			}, nil
		}
		return nil, err
	}
	return &set, nil
}

func (r *attendanceRepository) GetHoliday(ctx context.Context, tenantID uuid.UUID, date time.Time) (*domain.Holiday, error) {
	query := `SELECT id, tenant_id, name, date, applies_to FROM holidays WHERE tenant_id = ? AND date = ?`
	var h domain.Holiday
	err := r.db.QueryRowContext(ctx, query, tenantID, date.Format("2006-01-02")).Scan(&h.ID, &h.TenantID, &h.Name, &h.Date, &h.AppliesTo)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return &h, err
}

func (r *attendanceRepository) GetActiveActivities(ctx context.Context, tenantID uuid.UUID, currentTime time.Time) ([]*domain.Activity, error) {
	query := `SELECT id, tenant_id, name, is_mandatory, start_time, end_time, requires_checkout, replaces_daily_attendance 
              FROM activities WHERE tenant_id = ? AND start_time <= ? AND end_time >= ?`
	rows, err := r.db.QueryContext(ctx, query, tenantID, currentTime, currentTime)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var acts []*domain.Activity
	for rows.Next() {
		var a domain.Activity
		if err := rows.Scan(&a.ID, &a.TenantID, &a.Name, &a.IsMandatory, &a.StartTime, &a.EndTime, &a.RequiresCheckout, &a.ReplacesDailyAttendance); err != nil {
			return nil, err
		}
		acts = append(acts, &a)
	}
	return acts, nil
}

func (r *attendanceRepository) IsUserTargetedForActivity(ctx context.Context, activityID uuid.UUID, userID, classID, roleID uuid.UUID) (bool, error) {
	query := `SELECT COUNT(*) FROM activity_targets WHERE activity_id = ? 
              AND ((target_type = 'USER' AND target_id = ?) 
              OR (target_type = 'CLASS' AND target_id = ?) 
              OR (target_type = 'ROLE' AND target_id = ?))` // Note: MAJOR not included in this simple check for brevity
	var count int
	err := r.db.QueryRowContext(ctx, query, activityID, userID, classID, roleID).Scan(&count)
	return count > 0, err
}

func (r *attendanceRepository) GetTodayDailyAttendance(ctx context.Context, tenantID, userID uuid.UUID) (*domain.Attendance, error) {
	query := `SELECT id, tenant_id, user_id, type, method, check_in_at, check_out_at, status, notes 
              FROM attendances WHERE tenant_id = ? AND user_id = ? AND type = 'DAILY' AND DATE(check_in_at) = CURRENT_DATE LIMIT 1`
	var a domain.Attendance
	err := r.db.QueryRowContext(ctx, query, tenantID, userID).Scan(&a.ID, &a.TenantID, &a.UserID, &a.Type, &a.Method, &a.CheckInAt, &a.CheckOutAt, &a.Status, &a.Notes)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return &a, err
}

func (r *attendanceRepository) GetTodayActivityAttendance(ctx context.Context, activityID, userID uuid.UUID) (*domain.ActivityAttendance, error) {
	query := `SELECT id, activity_id, user_id, check_in_at, check_out_at, status 
              FROM activity_attendances WHERE activity_id = ? AND user_id = ? AND DATE(check_in_at) = CURRENT_DATE LIMIT 1`
	var a domain.ActivityAttendance
	err := r.db.QueryRowContext(ctx, query, activityID, userID).Scan(&a.ID, &a.ActivityID, &a.UserID, &a.CheckInAt, &a.CheckOutAt, &a.Status)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return &a, err
}

func (r *attendanceRepository) CreateDailyAttendance(ctx context.Context, att *domain.Attendance) error {
	query := `INSERT INTO attendances (id, tenant_id, user_id, type, method, check_in_at, status, notes) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`
	att.ID = uuid.New()
	_, err := r.db.ExecContext(ctx, query, att.ID, att.TenantID, att.UserID, att.Type, att.Method, att.CheckInAt, att.Status, att.Notes)
	return err
}

func (r *attendanceRepository) UpdateDailyAttendance(ctx context.Context, att *domain.Attendance) error {
	query := `UPDATE attendances SET check_out_at = ?, status = ? WHERE id = ?`
	_, err := r.db.ExecContext(ctx, query, att.CheckOutAt, att.Status, att.ID)
	return err
}

func (r *attendanceRepository) CreateActivityAttendance(ctx context.Context, att *domain.ActivityAttendance) error {
	query := `INSERT INTO activity_attendances (id, activity_id, user_id, check_in_at, status) VALUES (?, ?, ?, ?, ?)`
	att.ID = uuid.New()
	_, err := r.db.ExecContext(ctx, query, att.ID, att.ActivityID, att.UserID, att.CheckInAt, att.Status)
	return err
}

func (r *attendanceRepository) UpdateActivityAttendance(ctx context.Context, att *domain.ActivityAttendance) error {
	query := `UPDATE activity_attendances SET check_out_at = ?, status = ? WHERE id = ?`
	_, err := r.db.ExecContext(ctx, query, att.CheckOutAt, att.Status, att.ID)
	return err
}

func (r *attendanceRepository) CreateLateRecord(ctx context.Context, attendanceID uuid.UUID, reason string) error {
	query := `INSERT INTO attendance_lates (id, attendance_id, reason) VALUES (?, ?, ?)`
	_, err := r.db.ExecContext(ctx, query, uuid.New(), attendanceID, reason)
	return err
}

func (r *attendanceRepository) UpdateUserFaceID(ctx context.Context, userID uuid.UUID, faceID string) error {
	_, err := r.db.ExecContext(ctx, "UPDATE users SET face_encoding = ? WHERE id = ?", faceID, userID)
	return err
}

func (r *attendanceRepository) GetUserByIdentifier(ctx context.Context, tenantID uuid.UUID, method domain.AttendanceMethod, identifier string) (*uuid.UUID, *uuid.UUID, *uuid.UUID, error) {
	var query string
	switch method {
	case domain.MethodRFID:
		query = `SELECT u.id, u.class_id, ur.role_id FROM users u LEFT JOIN user_roles ur ON u.id = ur.user_id WHERE u.tenant_id = ? AND u.rfid_tag = ? LIMIT 1`
	case domain.MethodFace:
		query = `SELECT u.id, u.class_id, ur.role_id FROM users u LEFT JOIN user_roles ur ON u.id = ur.user_id WHERE u.tenant_id = ? AND u.face_encoding = ? LIMIT 1`
	case domain.MethodFingerprint:
		query = `SELECT u.id, u.class_id, ur.role_id FROM users u LEFT JOIN user_roles ur ON u.id = ur.user_id WHERE u.tenant_id = ? AND u.identifier = ? LIMIT 1`
	default:
		return nil, nil, nil, fmt.Errorf("unsupported method")
	}

	var userID uuid.UUID
	var classID, roleID sql.NullString
	
	err := r.db.QueryRowContext(ctx, query, tenantID, identifier).Scan(&userID, &classID, &roleID)
	if err != nil {
		return nil, nil, nil, err
	}
	
	var cID, rID *uuid.UUID
	if classID.Valid {
		parsed, _ := uuid.Parse(classID.String)
		cID = &parsed
	}
	if roleID.Valid {
		parsed, _ := uuid.Parse(roleID.String)
		rID = &parsed
	}
	
	return &userID, cID, rID, nil
}
