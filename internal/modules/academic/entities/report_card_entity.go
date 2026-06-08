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
