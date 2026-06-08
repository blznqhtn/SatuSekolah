package domain

import (
	"context"
	"time"

	"github.com/google/uuid"
)

// ==========================================
// REPORTS DOMAIN
// ==========================================

type ReportFormat string

const (
	FormatJSON  ReportFormat = "json"
	FormatExcel ReportFormat = "excel"
	FormatPDF   ReportFormat = "pdf"
)

// AttendanceReportRow represents one row of attendance summary
type AttendanceReportRow struct {
	UserID      uuid.UUID `json:"user_id"`
	UserName    string    `json:"user_name"`
	Role        string    `json:"role"`
	TotalDays   int       `json:"total_days"`
	PresentDays int       `json:"present_days"`
	AbsentDays  int       `json:"absent_days"`
	LateDays    int       `json:"late_days"`
	Percentage  float64   `json:"percentage"`
}

// FinancialReportRow represents ledger summary
type FinancialReportRow struct {
	Date         time.Time `json:"date"`
	TotalCredit  float64   `json:"total_credit"`
	TotalDebit   float64   `json:"total_debit"`
	NetBalance   float64   `json:"net_balance"`
	Transactions int       `json:"transactions"`
}

// AcademicReportRow represents academic performance summary
type AcademicReportRow struct {
	StudentID  uuid.UUID `json:"student_id"`
	StudentName string   `json:"student_name"`
	CourseName string    `json:"course_name"`
	QuizCount  int       `json:"quiz_count"`
	AvgScore   float64   `json:"avg_score"`
}

type ReportRepository interface {
	GetAttendanceReport(ctx context.Context, tenantID uuid.UUID, startDate, endDate time.Time) ([]*AttendanceReportRow, error)
	GetFinancialReport(ctx context.Context, tenantID uuid.UUID, startDate, endDate time.Time) ([]*FinancialReportRow, error)
	GetAcademicReport(ctx context.Context, tenantID uuid.UUID) ([]*AcademicReportRow, error)
}

type ReportUsecase interface {
	GenerateAttendanceReport(ctx context.Context, tenantID uuid.UUID, startDate, endDate time.Time, format ReportFormat) (interface{}, string, error)
	GenerateFinancialReport(ctx context.Context, tenantID uuid.UUID, startDate, endDate time.Time, format ReportFormat) (interface{}, string, error)
	GenerateAcademicReport(ctx context.Context, tenantID uuid.UUID, format ReportFormat) (interface{}, string, error)
}
