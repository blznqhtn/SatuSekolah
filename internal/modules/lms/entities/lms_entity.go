package entities

import (
	"database/sql"
	"time"

	"github.com/google/uuid"
)

type Course struct {
	ID        uuid.UUID    `json:"id"`
	TenantID  uuid.UUID    `json:"tenant_id"`
	Name      string       `json:"name"`
	StaffID uuid.UUID    `json:"staff_id"`
	CreatedAt time.Time    `json:"created_at"`
	DeletedAt sql.NullTime `json:"deleted_at"`
}

type Module struct {
	ID        uuid.UUID    `json:"id"`
	CourseID  uuid.UUID    `json:"course_id"`
	Title     string       `json:"title"`
	Content   string       `json:"content"`
	CreatedAt time.Time    `json:"created_at"`
	DeletedAt sql.NullTime `json:"deleted_at"`
}

type Quiz struct {
	ID       uuid.UUID    `json:"id"`
	ModuleID uuid.UUID    `json:"module_id"`
	Title    string       `json:"title"`
	DeletedAt sql.NullTime `json:"deleted_at"`
}

type Question struct {
	ID                 uuid.UUID    `json:"id"`
	QuizID             uuid.UUID    `json:"quiz_id"`
	Type               string       `json:"type"`
	QuestionText       string       `json:"question_text"`
	AIReferenceAnswer sql.NullString `json:"ai_reference_answer"`
	DeletedAt          sql.NullTime `json:"deleted_at"`
}

type StudentAnswer struct {
	ID          uuid.UUID      `json:"id"`
	QuestionID  uuid.UUID      `json:"question_id"`
	StudentID   uuid.UUID      `json:"student_id"`
	AnswerText  string         `json:"answer_text"`
	IsCorrect   sql.NullBool   `json:"is_correct"`
	AIScore     sql.NullFloat64 `json:"ai_score"`
	AIFeedback  sql.NullString `json:"ai_feedback"`
	CreatedAt   time.Time      `json:"created_at"`
}
