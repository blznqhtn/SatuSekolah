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
		WHERE tenant_id = $1 AND user_id = $2
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
		var idStr, tStr, uStr string
		if err := rows.Scan(&idStr, &tStr, &uStr, &n.Title, &n.Content, &n.Type, &n.IsRead, &n.ActionURL, &n.CreatedAt); err != nil {
			return nil, err
		}
		n.ID, _ = uuid.Parse(idStr)
		n.TenantID, _ = uuid.Parse(tStr)
		n.UserID, _ = uuid.Parse(uStr)
		notifs = append(notifs, &n)
	}
	return notifs, nil
}

func (r *notificationRepository) MarkAsRead(ctx context.Context, tenantID, userID, notificationID uuid.UUID) error {
	query := `UPDATE notifications SET is_read = TRUE WHERE id = $1 AND tenant_id = $2 AND user_id = $3`
	_, err := r.db.ExecContext(ctx, query, notificationID, tenantID, userID)
	return err
}

func (r *notificationRepository) DeleteNotification(ctx context.Context, tenantID, userID, notificationID uuid.UUID) error {
	query := `DELETE FROM notifications WHERE id = $1 AND tenant_id = $2 AND user_id = $3`
	_, err := r.db.ExecContext(ctx, query, notificationID, tenantID, userID)
	return err
}

func (r *notificationRepository) CountUnread(ctx context.Context, tenantID, userID uuid.UUID) (int, error) {
	query := `SELECT COUNT(*) FROM notifications WHERE is_read = FALSE AND tenant_id = $1 AND user_id = $2`
	var count int
	err := r.db.QueryRowContext(ctx, query, tenantID, userID).Scan(&count)
	return count, err
}

