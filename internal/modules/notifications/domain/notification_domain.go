package domain

import (
	"context"
	"time"

	"github.com/google/uuid"
)

type Notification struct {
	ID        uuid.UUID `json:"id"`
	TenantID  uuid.UUID `json:"tenant_id"`
	UserID    uuid.UUID `json:"user_id"`
	Title     string    `json:"title"`
	Content   string    `json:"content"`
	Type      string    `json:"type"`
	IsRead    bool      `json:"is_read"`
	ActionURL string    `json:"action_url"`
	CreatedAt time.Time `json:"created_at"`
}

type NotificationRepository interface {
	GetNotifications(ctx context.Context, tenantID, userID uuid.UUID) ([]*Notification, error)
	MarkAsRead(ctx context.Context, tenantID, userID, notificationID uuid.UUID) error
	DeleteNotification(ctx context.Context, tenantID, userID, notificationID uuid.UUID) error
	CountUnread(ctx context.Context, tenantID, userID uuid.UUID) (int, error)
}

type NotificationUsecase interface {
	GetNotifications(ctx context.Context, tenantID, userID uuid.UUID) ([]*Notification, error)
	MarkAsRead(ctx context.Context, tenantID, userID, notificationID uuid.UUID) error
	DeleteNotification(ctx context.Context, tenantID, userID, notificationID uuid.UUID) error
	CountUnread(ctx context.Context, tenantID, userID uuid.UUID) (int, error)
}
