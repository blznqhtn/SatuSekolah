package repository

import (
	"context"
	"database/sql"
	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/notifications/domain"
)

type notificationRepository struct {
	db *sql.DB
}

func NewNotificationRepository(db *sql.DB) domain.NotificationRepository {
	return &notificationRepository{db: db}
}

func (r *notificationRepository) GetNotifications(ctx context.Context, tenantID, userID uuid.UUID) ([]*domain.Notification, error) {
	query := `
		SELECT id, tenant_id, user_id, title, COALESCE(content, ''), COALESCE(type, ''), is_read, COALESCE(action_url, ''), created_at
		FROM notifications
		WHERE tenant_id = ? AND user_id = ?
		ORDER BY created_at DESC
	`
	rows, err := r.db.QueryContext(ctx, query, tenantID, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var notifs []*domain.Notification
	for rows.Next() {
		var n domain.Notification
		if err := rows.Scan(&n.ID, &n.TenantID, &n.UserID, &n.Title, &n.Content, &n.Type, &n.IsRead, &n.ActionURL, &n.CreatedAt); err != nil {
			return nil, err
		}
		notifs = append(notifs, &n)
	}
	return notifs, nil
}

func (r *notificationRepository) MarkAsRead(ctx context.Context, tenantID, userID, notificationID uuid.UUID) error {
	query := `UPDATE notifications SET is_read = TRUE WHERE id = ? AND tenant_id = ? AND user_id = ?`
	_, err := r.db.ExecContext(ctx, query, notificationID, tenantID, userID)
	return err
}

func (r *notificationRepository) DeleteNotification(ctx context.Context, tenantID, userID, notificationID uuid.UUID) error {
	query := `DELETE FROM notifications WHERE id = ? AND tenant_id = ? AND user_id = ?`
	_, err := r.db.ExecContext(ctx, query, notificationID, tenantID, userID)
	return err
}

func (r *notificationRepository) CountUnread(ctx context.Context, tenantID, userID uuid.UUID) (int, error) {
	query := `SELECT COUNT(*) FROM notifications WHERE is_read = FALSE AND tenant_id = ? AND user_id = ?`
	var count int
	err := r.db.QueryRowContext(ctx, query, tenantID, userID).Scan(&count)
	return count, err
}
