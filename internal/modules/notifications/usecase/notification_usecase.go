package usecase

import (
	"context"
	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/notifications/domain"
)

type notificationUsecase struct {
	repo domain.NotificationRepository
}

func NewNotificationUsecase(repo domain.NotificationRepository) domain.NotificationUsecase {
	return &notificationUsecase{repo: repo}
}

func (u *notificationUsecase) GetNotifications(ctx context.Context, tenantID, userID uuid.UUID) ([]*domain.Notification, error) {
	return u.repo.GetNotifications(ctx, tenantID, userID)
}

func (u *notificationUsecase) MarkAsRead(ctx context.Context, tenantID, userID, notificationID uuid.UUID) error {
	return u.repo.MarkAsRead(ctx, tenantID, userID, notificationID)
}

func (u *notificationUsecase) DeleteNotification(ctx context.Context, tenantID, userID, notificationID uuid.UUID) error {
	return u.repo.DeleteNotification(ctx, tenantID, userID, notificationID)
}

func (u *notificationUsecase) CountUnread(ctx context.Context, tenantID, userID uuid.UUID) (int, error) {
	return u.repo.CountUnread(ctx, tenantID, userID)
}
