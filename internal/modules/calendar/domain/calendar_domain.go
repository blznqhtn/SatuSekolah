package domain

import (
	"context"
	"time"

	"github.com/google/uuid"
)

type CalendarEvent struct {
	ID           uuid.UUID  `json:"id"`
	TenantID     uuid.UUID  `json:"tenant_id"`
	Title        string     `json:"title"`
	Description  string     `json:"description"`
	EventDate    string     `json:"event_date"` // YYYY-MM-DD
	StartTime    *string    `json:"start_time"` // HH:MM:SS
	EndTime      *string    `json:"end_time"`   // HH:MM:SS
	Location     string     `json:"location"`
	Category     string     `json:"category"` // UJIAN, KEGIATAN, LIBUR, dll
	Status       string     `json:"status"`
	Attachment   string     `json:"attachment_url"`
	CreatedBy    uuid.UUID  `json:"created_by"`
	TargetUserID *uuid.UUID `json:"target_user_id,omitempty"`
	CreatedAt    time.Time  `json:"created_at"`
	UpdatedAt    time.Time  `json:"updated_at"`
}

type CalendarRepository interface {
	GetEventsByMonth(ctx context.Context, tenantID uuid.UUID, year, month int, targetUserID *uuid.UUID) ([]*CalendarEvent, error)
	GetEventByID(ctx context.Context, tenantID, eventID uuid.UUID) (*CalendarEvent, error)
	CreateEvent(ctx context.Context, event *CalendarEvent) error
	UpdateEvent(ctx context.Context, event *CalendarEvent) error
	DeleteEvent(ctx context.Context, tenantID, eventID uuid.UUID) error
}

type CalendarUsecase interface {
	GetEventsByMonth(ctx context.Context, tenantID uuid.UUID, year, month int, targetUserID *uuid.UUID) ([]*CalendarEvent, error)
	GetEventByID(ctx context.Context, tenantID, eventID uuid.UUID) (*CalendarEvent, error)
	CreateEvent(ctx context.Context, req *CalendarEvent) (*CalendarEvent, error)
	UpdateEvent(ctx context.Context, req *CalendarEvent) (*CalendarEvent, error)
	DeleteEvent(ctx context.Context, tenantID, eventID uuid.UUID) error
}
