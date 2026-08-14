package repository

import (
	"context"
	"database/sql"
	"time"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/presence/domain"
)

type presenceRepository struct {
	db *sql.DB
}

func NewPresenceRepository(db *sql.DB) domain.PresenceRepository {
	return &presenceRepository{db: db}
}

func (r *presenceRepository) GetSummary(ctx context.Context, tenantID, studentID uuid.UUID) (*domain.AttendanceSummary, error) {
	// Query daily attendances for summary
	query := `
		SELECT status, COUNT(*) as count
		FROM attendances
		WHERE tenant_id = ? AND user_id = ?
		GROUP BY status
	`
	rows, err := r.db.QueryContext(ctx, query, tenantID, studentID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	summary := &domain.AttendanceSummary{}
	for rows.Next() {
		var status string
		var count int
		if err := rows.Scan(&status, &count); err != nil {
			return nil, err
		}
		switch status {
		case "PRESENT", "LATE":
			summary.TotalHadir += count
		case "EXCUSED":
			summary.TotalIzin += count
		case "SICK": // if we added SICK, otherwise map appropriately. Let's assume ABSENT/EXCUSED
			summary.TotalSakit += count
		case "ABSENT":
			summary.TotalAlpha += count
		}
	}
	return summary, nil
}

func (r *presenceRepository) GetWeekly(ctx context.Context, tenantID, studentID uuid.UUID, startDate, endDate time.Time) ([]*domain.WeeklyAttendance, error) {
	query := `
		SELECT DATE(check_in_at) as date_str, status
		FROM attendances
		WHERE tenant_id = ? AND user_id = ? AND check_in_at >= ? AND check_in_at <= ?
	`
	rows, err := r.db.QueryContext(ctx, query, tenantID, studentID, startDate, endDate)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []*domain.WeeklyAttendance
	for rows.Next() {
		var wa domain.WeeklyAttendance
		if err := rows.Scan(&wa.Date, &wa.Status); err != nil {
			return nil, err
		}
		results = append(results, &wa)
	}
	return results, nil
}

func (r *presenceRepository) GetHistory(ctx context.Context, tenantID, studentID uuid.UUID) ([]*domain.ScheduleAttendance, error) {
	query := `
		SELECT sa.id, sa.created_at, sa.status, sa.notes,
		       c.name as course_name, 
		       cs.start_time, cs.end_time,
		       u.name as teacher_name
		FROM schedule_attendances sa
		JOIN class_schedules cs ON sa.schedule_id = cs.id
		JOIN courses c ON cs.course_id = c.id
		LEFT JOIN users u ON sa.recorded_by = u.id
		WHERE sa.tenant_id = ? AND sa.student_id = ?
		ORDER BY sa.created_at DESC
	`
	rows, err := r.db.QueryContext(ctx, query, tenantID, studentID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []*domain.ScheduleAttendance
	for rows.Next() {
		var sa domain.ScheduleAttendance
		var createdAt time.Time
		var course, startT, endT string
		var teacher sql.NullString
		
		if err := rows.Scan(&sa.ID, &createdAt, &sa.Status, &sa.Notes, &course, &startT, &endT, &teacher); err != nil {
			return nil, err
		}

		sa.Date = createdAt.Format("2006-01-02")
		sa.Day = getIndonesianDay(createdAt.Weekday())
		sa.Course = course
		sa.TimeStart = startT
		sa.TimeEnd = endT
		if teacher.Valid {
			sa.Teacher = teacher.String
		}
		results = append(results, &sa)
	}
	return results, nil
}

func getIndonesianDay(w time.Weekday) string {
	days := []string{"Minggu", "Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu"}
	return days[w]
}
