package http

import (
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/middleware"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/dashboard/domain"
)

type DashboardHandler struct {
	usecase domain.DashboardUsecase
}

func NewDashboardHandler(usecase domain.DashboardUsecase) *DashboardHandler {
	return &DashboardHandler{usecase: usecase}
}

func (h *DashboardHandler) GetSummary(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)
	userID, _ := uuid.Parse(claims.UserID)

	// If parent selects a child
	childIDStr := c.Query("child_id")
	if childIDStr != "" {
		if parsed, err := uuid.Parse(childIDStr); err == nil {
			userID = parsed
		}
	}

	summary, err := h.usecase.GetSummary(c.Context(), tenantID, userID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"data": summary})
}

func (h *DashboardHandler) GetActivities(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)
	userID, _ := uuid.Parse(claims.UserID)

	childIDStr := c.Query("child_id")
	if childIDStr != "" {
		if parsed, err := uuid.Parse(childIDStr); err == nil {
			userID = parsed
		}
	}

	activities, err := h.usecase.GetActivities(c.Context(), tenantID, userID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	if activities == nil {
		activities = []*domain.ActivityLog{}
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"data": activities})
}
