package entities

import (
	"database/sql"
	"time"

	"github.com/google/uuid"
)

type AcademicTerm struct {
	ID             uuid.UUID `json:"id"`
	TenantID       uuid.UUID `json:"tenant_id"`
	AcademicYearID uuid.UUID `json:"academic_year_id"`
	Name           string    `json:"name"`
	IsActive       bool      `json:"is_active"`
	CreatedAt      time.Time `json:"created_at"`
}

type ReportCard struct {
	ID            uuid.UUID    `json:"id"`
	TenantID      uuid.UUID    `json:"tenant_id"`
	TermID        uuid.UUID    `json:"term_id"`
	StudentID     uuid.UUID    `json:"student_id"`
	ClassRank     sql.NullInt32 `json:"class_rank"`
	HomeroomNotes string       `json:"homeroom_notes"`
	CreatedAt     time.Time    `json:"created_at"`
	UpdatedAt     sql.NullTime `json:"updated_at"`
	UpdatedBy     uuid.UUID    `json:"updated_by"`
}

type ReportCardGrade struct {
	ID           uuid.UUID    `json:"id"`
	ReportCardID uuid.UUID    `json:"report_card_id"`
	CourseID     uuid.UUID    `json:"course_id"`
	Score        int          `json:"score"`
	Predicate    string       `json:"predicate"`
	Description  string       `json:"description"`
	CreatedAt    time.Time    `json:"created_at"`
	UpdatedAt    sql.NullTime `json:"updated_at"`
}

type GradeComponent struct {
	ID        uuid.UUID    `json:"id"`
	TenantID  uuid.UUID    `json:"tenant_id"`
	CourseID  uuid.UUID    `json:"course_id"`
	Name      string       `json:"name"`
	Weight    float64      `json:"weight"`
	CreatedAt time.Time    `json:"created_at"`
	UpdatedAt sql.NullTime `json:"updated_at"`
}

type StudentGrade struct {
	ID               uuid.UUID      `json:"id"`
	TenantID         uuid.UUID      `json:"tenant_id"`
	StudentID        uuid.UUID      `json:"student_id"`
	GradeComponentID uuid.UUID      `json:"grade_component_id"`
	TermID           uuid.UUID      `json:"term_id"`
	Score            float64        `json:"score"`
	TeacherNotes     sql.NullString `json:"teacher_notes"`
	CreatedAt        time.Time      `json:"created_at"`
	UpdatedAt        sql.NullTime   `json:"updated_at"`
	UpdatedBy        uuid.UUID      `json:"updated_by"`
}

type ReportCardNote struct {
	ID           uuid.UUID    `json:"id"`
	ReportCardID uuid.UUID    `json:"report_card_id"`
	Category     string       `json:"category"`
	Notes        string       `json:"notes"`
	CreatedAt    time.Time    `json:"created_at"`
	UpdatedAt    sql.NullTime `json:"updated_at"`
	UpdatedBy    uuid.UUID    `json:"updated_by"`
}
