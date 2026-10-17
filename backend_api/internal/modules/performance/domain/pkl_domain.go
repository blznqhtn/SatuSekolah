package domain

import (
	"context"
	"time"

	"github.com/google/uuid"
)

type PklStatus string

const (
	PklPending  PklStatus = "PENDING"
	PklApproved PklStatus = "APPROVED"
	PklRejected PklStatus = "REJECTED"
)

// Existing Monitoring (General PKL)
type PklMonitoring struct {
	ID                 uuid.UUID  `json:"id"`
	TenantID           uuid.UUID  `json:"tenant_id"`
	StudentID          uuid.UUID  `json:"student_id"`
	SupervisorStaffID   uuid.UUID  `json:"supervisor_staff_id"`
	DocumentationURL   string     `json:"documentation_url"`
	Notes              string     `json:"notes"`
	Status             PklStatus  `json:"status"`
	PrincipalScore     *float64   `json:"principal_score"`
	PrincipalNotes     *string    `json:"principal_notes"`
	EvaluatedAt        *time.Time `json:"evaluated_at"`
	CreatedAt          time.Time  `json:"created_at"`
}

type PerformanceSetting struct {
	TenantID          uuid.UUID `json:"tenant_id"`
	PrincipalStaffID   uuid.UUID `json:"principal_staff_id"`
	CreatedAt         time.Time `json:"created_at"`
}

// ------------------------------------------
// Bimbingan Jurnal PKL (Mentoring & Journal)
// ------------------------------------------

type PklMentorship struct {
	ID             uuid.UUID `json:"id"`
	TenantID       uuid.UUID `json:"tenant_id"`
	AcademicYearID uuid.UUID `json:"academic_year_id"`
	StudentID      uuid.UUID `json:"student_id"`
	MentorID       uuid.UUID `json:"mentor_id"`
	CreatedAt      time.Time `json:"created_at"`
}

type PklMentoringSchedule struct {
	ID           uuid.UUID `json:"id"`
	MentorshipID uuid.UUID `json:"mentorship_id"`
	ScheduleDate time.Time `json:"schedule_date"`
	ZoomLink     *string   `json:"zoom_link"`
	MentorNotes  *string   `json:"mentor_notes"` // E2EE cipher
	CreatedAt    time.Time `json:"created_at"`
}

type PklJournal struct {
	ID           uuid.UUID  `json:"id"`
	ScheduleID   uuid.UUID  `json:"schedule_id"`
	Description  string     `json:"description"`   // E2EE cipher
	DocumentURLs string     `json:"document_urls"` // Encrypted S3 URLs JSON
	Status       PklStatus  `json:"status"`
	Feedback     *string    `json:"feedback"`      // E2EE cipher
	CreatedAt    time.Time  `json:"created_at"`
	UpdatedAt    *time.Time `json:"updated_at"`
}

// ------------------------------------------
// Final Report & Hubungan Industri
// ------------------------------------------

type PklFinalReportSetting struct {
	ID          uuid.UUID  `json:"id"`
	TenantID    uuid.UUID  `json:"tenant_id"`
	TargetType  string     `json:"target_type"` // e.g. "CLASS", "MAJOR", "ALL"
	TargetID    *uuid.UUID `json:"target_id"`
	StartDate   *time.Time `json:"start_date"`
	EndDate     *time.Time `json:"end_date"`
}

type PklFinalReport struct {
	ID              uuid.UUID  `json:"id"`
	StudentID       uuid.UUID  `json:"student_id"`
	DocumentURL     string     `json:"document_url"` // Encrypted S3 URL
	Status          PklStatus  `json:"status"`
	Notes           *string    `json:"notes"` // Rejection notes
	ApprovedBy      *uuid.UUID `json:"approved_by"`
	CreatedAt       time.Time  `json:"created_at"`
	UpdatedAt       *time.Time `json:"updated_at"`
}

// ------------------------------------------
// Interfaces
// ------------------------------------------

type PklRepository interface {
	ExecTx(ctx context.Context, fn func(repo PklRepository) error) error

	// Existing
	GetSetting(ctx context.Context, tenantID uuid.UUID) (*PerformanceSetting, error)
	UpsertSetting(ctx context.Context, setting *PerformanceSetting) error
	CreateMonitoring(ctx context.Context, pkl *PklMonitoring) error
	GetMonitoring(ctx context.Context, pklID uuid.UUID) (*PklMonitoring, error)
	UpdateMonitoringEvaluation(ctx context.Context, pklID uuid.UUID, score float64, notes string, status PklStatus) error

	// Mentorship
	AssignMentor(ctx context.Context, mentorships []*PklMentorship) error
	GetMentorshipByStudent(ctx context.Context, studentID uuid.UUID) (*PklMentorship, error)
	GetMentorshipsByMentor(ctx context.Context, mentorID uuid.UUID, academicYearID uuid.UUID) ([]*PklMentorship, error)

	// Scheduling
	CreateSchedule(ctx context.Context, schedule *PklMentoringSchedule) error
	GetScheduleByID(ctx context.Context, id uuid.UUID) (*PklMentoringSchedule, error)
	GetSchedulesByMentorship(ctx context.Context, mentorshipID uuid.UUID) ([]*PklMentoringSchedule, error)

	// Journal
	SaveJournal(ctx context.Context, journal *PklJournal) error
	GetJournalBySchedule(ctx context.Context, scheduleID uuid.UUID) (*PklJournal, error)
	GetJournalByID(ctx context.Context, id uuid.UUID) (*PklJournal, error)

	// Final Report Settings & Reports
	UpsertFinalReportSetting(ctx context.Context, setting *PklFinalReportSetting) error
	GetFinalReportSetting(ctx context.Context, tenantID uuid.UUID, studentClassID uuid.UUID, studentMajorID uuid.UUID) (*PklFinalReportSetting, error)
	SaveFinalReport(ctx context.Context, report *PklFinalReport) error
	GetFinalReportByID(ctx context.Context, id uuid.UUID) (*PklFinalReport, error)
}

type PklUsecase interface {
	// Existing
	ConfigureSetting(ctx context.Context, setting *PerformanceSetting, adminID uuid.UUID) error
	ReportMonitoring(ctx context.Context, pkl *PklMonitoring) error
	EvaluateMonitoring(ctx context.Context, pklID uuid.UUID, principalID uuid.UUID, score float64, notes string, status PklStatus) error

	// Hubungan Industri Monitoring (to E-Kinerja)
	ReportHubinMonitoring(ctx context.Context, tenantID uuid.UUID, staffID uuid.UUID, fileURL string, title string) error

	// Mentorship
	AssignMentors(ctx context.Context, tenantID uuid.UUID, academicYearID uuid.UUID, studentIDs []uuid.UUID, mentorID uuid.UUID) error

	// Schedule
	CreateSchedule(ctx context.Context, mentorID uuid.UUID, schedule *PklMentoringSchedule) error

	// Journal
	SubmitJournal(ctx context.Context, studentID uuid.UUID, scheduleID uuid.UUID, description string, documentURLs string) error
	ReviewJournal(ctx context.Context, mentorID uuid.UUID, journalID uuid.UUID, status PklStatus, feedback string) error

	// Final Report
	ConfigureFinalReport(ctx context.Context, tenantID uuid.UUID, setting *PklFinalReportSetting) error
	SubmitFinalReport(ctx context.Context, tenantID uuid.UUID, studentID uuid.UUID, documentURL string) error
	VerifyFinalReport(ctx context.Context, tenantID uuid.UUID, hubinID uuid.UUID, reportID uuid.UUID, status PklStatus, notes string) error
}
