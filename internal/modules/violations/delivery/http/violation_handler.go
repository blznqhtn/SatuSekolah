package http

import (
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/middleware"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/violations/domain"
)

type ViolationHandler struct {
	uc domain.ViolationUsecase
}

func NewViolationHandler(uc domain.ViolationUsecase) *ViolationHandler {
	return &ViolationHandler{uc: uc}
}

// GetViolationTypes returns all violation types available for this tenant
// (includes global system defaults + tenant-custom ones)
func (h *ViolationHandler) GetViolationTypes(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, err := uuid.Parse(claims.TenantID)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid tenant"})
	}
	types, err := h.uc.GetViolationTypes(c.Context(), tenantID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"data": types})
}

// CreateViolationType lets authorized staff (MANAGE_VIOLATIONS) add a new type
func (h *ViolationHandler) CreateViolationType(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)
	staffID, _ := uuid.Parse(claims.UserID)

	var req domain.CreateViolationTypeRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}
	if req.Name == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "name is required"})
	}

	vt, err := h.uc.CreateViolationType(c.Context(), tenantID, staffID, &req)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(fiber.Map{"data": vt})
}

// ToggleViolationType activates or deactivates a violation type
func (h *ViolationHandler) ToggleViolationType(c *fiber.Ctx) error {
	id := c.Params("id")
	type req struct {
		IsActive bool `json:"is_active"`
	}
	var body req
	if err := c.BodyParser(&body); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}
	if err := h.uc.ToggleViolationType(c.Context(), id, body.IsActive); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "violation type updated"})
}

// DeleteViolationType removes a non-system violation type
func (h *ViolationHandler) DeleteViolationType(c *fiber.Ctx) error {
	id := c.Params("id")
	if err := h.uc.DeleteViolationType(c.Context(), id); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "violation type deleted"})
}

// RecordViolation lets authorized staff record one or more violations on a user
// (requires evidence photo + selected violation type checkboxes)
func (h *ViolationHandler) RecordViolation(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)
	staffID, _ := uuid.Parse(claims.UserID)

	var req domain.RecordViolationRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}

	records, err := h.uc.RecordViolation(c.Context(), tenantID, staffID, &req)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(fiber.Map{
		"message": "violation(s) recorded successfully",
		"data":    records,
	})
}

// GetUserViolationHistory returns violation history + total points for a user
func (h *ViolationHandler) GetUserViolationHistory(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)

	userIDStr := c.Params("user_id")
	userID, err := uuid.Parse(userIDStr)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid user_id"})
	}

	violations, totalPoints, err := h.uc.GetUserViolationHistory(c.Context(), tenantID, userID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{
		"user_id":      userID,
		"total_points": totalPoints,
		"violations":   violations,
	})
}
