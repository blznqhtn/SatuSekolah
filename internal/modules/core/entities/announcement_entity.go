package entities

import (
	"database/sql"
	"time"

	"github.com/google/uuid"
)

type Announcement struct {
	ID             uuid.UUID    `json:"id"`
	TenantID       uuid.UUID    `json:"tenant_id"`
	Title          string       `json:"title"`
	Content        string       `json:"content"`
	Type           string       `json:"type"`
	TargetAudience string       `json:"target_audience"`
	EventDate      sql.NullTime `json:"event_date"`
	CreatedAt      time.Time    `json:"created_at"`
	UpdatedAt      sql.NullTime `json:"updated_at"`
	DeletedAt      sql.NullTime `json:"deleted_at"`
	UpdatedBy      uuid.UUID    `json:"updated_by"`
}
