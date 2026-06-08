package repository

import (
	"context"
	"database/sql"
	"time"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/reports/domain"
)

type reportRepository struct {
	db *sql.DB
}

func NewReportRepository(db *sql.DB) domain.ReportRepository {
	return &reportRepository{db: db}
}

func (r *reportRepository) GetAttendanceReport(ctx context.Context, tenantID uuid.UUID, startDate, endDate time.Time) ([]*domain.AttendanceReportRow, error) {
	q := `
		SELECT 
			u.id, u.full_name, r.name,
			COUNT(a.id) AS total_days,
			SUM(CASE WHEN a.status = 'PRESENT' THEN 1 ELSE 0 END) AS present_days,
			SUM(CASE WHEN a.status = 'ABSENT' THEN 1 ELSE 0 END) AS absent_days,
			SUM(CASE WHEN a.status = 'LATE' THEN 1 ELSE 0 END) AS late_days
		FROM users u
		JOIN roles r ON u.role_id = r.id
		LEFT JOIN attendances a ON a.user_id = u.id AND a.created_at BETWEEN $2 AND $3
		WHERE u.tenant_id = $1
		GROUP BY u.id, u.full_name, r.name
		ORDER BY u.full_name ASC
	`
	rows, err := r.db.QueryContext(ctx, q, tenantID, startDate, endDate)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var report []*domain.AttendanceReportRow
	for rows.Next() {
		var row domain.AttendanceReportRow
		if err := rows.Scan(&row.UserID, &row.UserName, &row.Role, &row.TotalDays, &row.PresentDays, &row.AbsentDays, &row.LateDays); err != nil {
			return nil, err
		}
		if row.TotalDays > 0 {
			row.Percentage = float64(row.PresentDays) / float64(row.TotalDays) * 100
		}
		report = append(report, &row)
	}
	return report, nil
}

func (r *reportRepository) GetFinancialReport(ctx context.Context, tenantID uuid.UUID, startDate, endDate time.Time) ([]*domain.FinancialReportRow, error) {
	q := `
		SELECT 
			DATE(wl.created_at) AS txn_date,
			COALESCE(SUM(CASE WHEN wl.transaction_type = 'CREDIT' THEN wl.amount ELSE 0 END), 0) AS total_credit,
			COALESCE(SUM(CASE WHEN wl.transaction_type = 'DEBIT' THEN wl.amount ELSE 0 END), 0) AS total_debit,
			COUNT(wl.id) AS transactions
		FROM wallet_ledgers wl
		JOIN users u ON wl.user_id = u.id
		WHERE u.tenant_id = $1 AND wl.created_at BETWEEN $2 AND $3
		GROUP BY DATE(wl.created_at)
		ORDER BY txn_date ASC
	`
	rows, err := r.db.QueryContext(ctx, q, tenantID, startDate, endDate)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var report []*domain.FinancialReportRow
	for rows.Next() {
		var row domain.FinancialReportRow
		if err := rows.Scan(&row.Date, &row.TotalCredit, &row.TotalDebit, &row.Transactions); err != nil {
			return nil, err
		}
		row.NetBalance = row.TotalCredit - row.TotalDebit
		report = append(report, &row)
	}
	return report, nil
}

func (r *reportRepository) GetAcademicReport(ctx context.Context, tenantID uuid.UUID) ([]*domain.AcademicReportRow, error) {
	q := `
		SELECT 
			u.id, u.full_name, c.name,
			COUNT(DISTINCT q.id) AS quiz_count,
			COALESCE(AVG(sa.ai_score), 0) AS avg_score
		FROM users u
		JOIN courses c ON c.tenant_id = u.tenant_id
		JOIN modules m ON m.course_id = c.id
		JOIN quizzes q ON q.module_id = m.id
		LEFT JOIN questions qq ON qq.quiz_id = q.id
		LEFT JOIN student_answers sa ON sa.question_id = qq.id AND sa.student_id = u.id
		WHERE u.tenant_id = $1
		GROUP BY u.id, u.full_name, c.name
		HAVING COUNT(sa.id) > 0
		ORDER BY u.full_name ASC
	`
	rows, err := r.db.QueryContext(ctx, q, tenantID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var report []*domain.AcademicReportRow
	for rows.Next() {
		var row domain.AcademicReportRow
		if err := rows.Scan(&row.StudentID, &row.StudentName, &row.CourseName, &row.QuizCount, &row.AvgScore); err != nil {
			return nil, err
		}
		report = append(report, &row)
	}
	return report, nil
}
