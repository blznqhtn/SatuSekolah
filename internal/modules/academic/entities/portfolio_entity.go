package entities

import (
	"database/sql"
	"time"

	"github.com/google/uuid"
)

type StudentPortfolio struct {
	ID           uuid.UUID    `json:"id"`
	StudentID    uuid.UUID    `json:"student_id"`
	Title        string       `json:"title"`
	Description  string       `json:"description"`
	ProjectURL   string       `json:"project_url"`
	ThumbnailURL string       `json:"thumbnail_url"`
	CreatedAt    time.Time    `json:"created_at"`
	UpdatedAt    sql.NullTime `json:"updated_at"`
	DeletedAt    sql.NullTime `json:"deleted_at"`
}
