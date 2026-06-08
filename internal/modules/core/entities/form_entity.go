package entities

import (
	"database/sql"
	"encoding/json"
	"time"

	"github.com/google/uuid"
)

type DynamicForm struct {
	ID             uuid.UUID    `json:"id"`
	TenantID       uuid.UUID    `json:"tenant_id"`
	Title          string       `json:"title"`
	Description    string       `json:"description"`
	StartDate      time.Time    `json:"start_date"`
	EndDate        time.Time    `json:"end_date"`
	TargetAudience string       `json:"target_audience"`
	IsActive       bool         `json:"is_active"`
	CreatedBy      uuid.UUID    `json:"created_by"`
	CreatedAt      time.Time    `json:"created_at"`
	UpdatedAt      sql.NullTime `json:"updated_at"`
	DeletedAt      sql.NullTime `json:"deleted_at"`
}

type FormQuestion struct {
	ID           uuid.UUID       `json:"id"`
	FormID       uuid.UUID       `json:"form_id"`
	QuestionType string          `json:"question_type"`
	QuestionText string          `json:"question_text"`
	IsRequired   bool            `json:"is_required"`
	OrderIndex   int             `json:"order_index"`
	Metadata     json.RawMessage `json:"metadata"`
}

type FormResponse struct {
	ID          uuid.UUID `json:"id"`
	FormID      uuid.UUID `json:"form_id"`
	ResponderID uuid.UUID `json:"responder_id"`
	CreatedAt   time.Time `json:"created_at"`
}

type FormAnswer struct {
	ID         uuid.UUID `json:"id"`
	ResponseID uuid.UUID `json:"response_id"`
	QuestionID uuid.UUID `json:"question_id"`
	AnswerText string    `json:"answer_text"`
}
