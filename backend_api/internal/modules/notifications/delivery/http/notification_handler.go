package http

import (
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/middleware"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/notifications/domain"
)

type NotificationHandler struct {
	usecase domain.NotificationUsecase
}

func NewNotificationHandler(usecase domain.NotificationUsecase) *NotificationHandler {
	return &NotificationHandler{usecase: usecase}
}

func (h *NotificationHandler) GetNotifications(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)
	userID, _ := uuid.Parse(claims.UserID)

	notifs, err := h.usecase.GetNotifications(c.Context(), tenantID, userID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	
	unreadCount, _ := h.usecase.CountUnread(c.Context(), tenantID, userID)

	if notifs == nil {
		notifs = []*domain.Notification{}
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{
		"data": notifs,
		"unread_count": unreadCount,
	})
}

func (h *NotificationHandler) MarkAsRead(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)
	userID, _ := uuid.Parse(claims.UserID)
	
	notifID, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid notification id"})
	}

	if err := h.usecase.MarkAsRead(c.Context(), tenantID, userID, notifID); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "marked as read"})
}

func (h *NotificationHandler) DeleteNotification(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)
	userID, _ := uuid.Parse(claims.UserID)
	
	notifID, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid notification id"})
	}

	if err := h.usecase.DeleteNotification(c.Context(), tenantID, userID, notifID); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "notification deleted"})
}
