package http

import (
	"strconv"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/middleware"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/calendar/domain"
)

type CalendarHandler struct {
	usecase domain.CalendarUsecase
}

func NewCalendarHandler(usecase domain.CalendarUsecase) *CalendarHandler {
	return &CalendarHandler{usecase: usecase}
}

func (h *CalendarHandler) GetEventsByMonth(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)

	year, err := strconv.Atoi(c.Params("year"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid year format"})
	}
	month, err := strconv.Atoi(c.Params("month"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid month format"})
	}

	var targetUserID *uuid.UUID
	// If the user is a student or parent, maybe we filter by their target user ID.
	// But according to requirements, we should get ALL global events + events specific to this user.
	if claims.Role == "student" || claims.Role == "parent" {
		uid, _ := uuid.Parse(claims.UserID)
		targetUserID = &uid
	}

	events, err := h.usecase.GetEventsByMonth(c.Context(), tenantID, year, month, targetUserID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	if events == nil {
		events = []*domain.CalendarEvent{}
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{"data": events})
}

func (h *CalendarHandler) CreateEvent(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)
	userID, _ := uuid.Parse(claims.UserID)

	var req domain.CalendarEvent
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid request payload"})
	}

	req.TenantID = tenantID
	req.CreatedBy = userID

	event, err := h.usecase.CreateEvent(c.Context(), &req)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusCreated).JSON(fiber.Map{"data": event})
}

func (h *CalendarHandler) UpdateEvent(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)

	eventID, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid event ID format"})
	}

	var req domain.CalendarEvent
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid request payload"})
	}
	req.ID = eventID
	req.TenantID = tenantID

	event, err := h.usecase.UpdateEvent(c.Context(), &req)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{"data": event})
}

func (h *CalendarHandler) DeleteEvent(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)

	eventID, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid event ID format"})
	}

	if err := h.usecase.DeleteEvent(c.Context(), tenantID, eventID); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.SendStatus(fiber.StatusNoContent)
}
