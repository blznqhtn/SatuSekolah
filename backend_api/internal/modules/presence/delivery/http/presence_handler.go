package http

import (
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/middleware"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/presence/domain"
)

type PresenceHandler struct {
	usecase domain.PresenceUsecase
}

func NewPresenceHandler(usecase domain.PresenceUsecase) *PresenceHandler {
	return &PresenceHandler{usecase: usecase}
}

func (h *PresenceHandler) GetSummary(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)
	userID, _ := uuid.Parse(claims.UserID)

	studentIDStr := c.Query("child_id")
	if studentIDStr != "" {
		if parsed, err := uuid.Parse(studentIDStr); err == nil {
			userID = parsed
		}
	}

	summary, err := h.usecase.GetSummary(c.Context(), tenantID, userID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	if summary == nil {
		summary = &domain.AttendanceSummary{}
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{"data": summary})
}

func (h *PresenceHandler) GetWeekly(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)
	userID, _ := uuid.Parse(claims.UserID)

	studentIDStr := c.Query("child_id")
	if studentIDStr != "" {
		if parsed, err := uuid.Parse(studentIDStr); err == nil {
			userID = parsed
		}
	}

	// For simulation, let's use current time.
	// Optionally can get date from query string.
	weekly, err := h.usecase.GetWeekly(c.Context(), tenantID, userID, time.Now())
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	if weekly == nil {
		weekly = []*domain.WeeklyAttendance{}
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{"data": weekly})
}

func (h *PresenceHandler) GetHistory(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)
	userID, _ := uuid.Parse(claims.UserID)

	studentIDStr := c.Query("child_id")
	if studentIDStr != "" {
		if parsed, err := uuid.Parse(studentIDStr); err == nil {
			userID = parsed
		}
	}

	history, err := h.usecase.GetHistory(c.Context(), tenantID, userID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	if history == nil {
		history = []*domain.ScheduleAttendance{}
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{"data": history})
}
