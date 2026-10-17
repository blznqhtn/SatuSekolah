package http

import (
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/middleware"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/attendance/domain"
)

type AttendanceHandler struct {
	uc domain.AttendanceUsecase
}

func NewAttendanceHandler(uc domain.AttendanceUsecase) *AttendanceHandler {
	return &AttendanceHandler{uc: uc}
}

// RouteIotPresence is the static IoT device endpoint
func (h *AttendanceHandler) RouteIotPresence(c *fiber.Ctx) error {
	var req domain.PresenceRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid request body"})
	}

	if req.TenantID == uuid.Nil || req.Identifier == "" || req.Method == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "tenant_id, method, and identifier are required"})
	}

	res, err := h.uc.ProcessPresence(c.Context(), &req)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusOK).JSON(res)
}

// RegisterFace handles the 6-image face registration
func (h *AttendanceHandler) RegisterFace(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	userID, _ := uuid.Parse(claims.UserID)

	var req domain.FaceRegistrationRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid request body"})
	}

	faceID, err := h.uc.RegisterFace(c.Context(), userID, &req)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{
		"message": "Face registered successfully",
		"face_id": faceID,
	})
}
