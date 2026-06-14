package http

import (
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/middleware"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/spmb/domain"
)

type SpmbHandler struct{
	usecase domain.SpmbUsecase
}

func NewSpmbHandler(usecase domain.SpmbUsecase) *SpmbHandler {
	return &SpmbHandler{usecase: usecase}
}

func (h *SpmbHandler) GetBatches(c *fiber.Ctx) error {
	return c.JSON(fiber.Map{"message": "GetBatches endpoint stub"})
}

func (h *SpmbHandler) GetPublicSchools(c *fiber.Ctx) error {
	schools, err := h.usecase.GetPublicSchools(c.Context())
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"data": schools})
}

func (h *SpmbHandler) RegisterSpmb(c *fiber.Ctx) error {
	claims, ok := c.Locals("claims").(*middleware.Claims)
	if !ok || claims == nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "unauthorized"})
	}

	var req domain.SpmbRegistration
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}

	req.ID = uuid.New()
	req.ParentID = uuid.MustParse(claims.UserID)
	req.TenantID = uuid.MustParse(claims.TenantID)
	req.RegistrationStatus = "PENDING"
	req.CreatedAt = time.Now()

	if err := h.usecase.RegisterSpmb(c.Context(), &req); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "failed to register SPMB: " + err.Error()})
	}

	return c.Status(fiber.StatusCreated).JSON(fiber.Map{
		"message": "SPMB registration created successfully",
		"data": req,
	})
}

// SimulatePayment is a mock endpoint for testing payment completion
func (h *SpmbHandler) SimulatePayment(c *fiber.Ctx) error {
	idStr := c.Params("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid registration ID"})
	}

	// In real app, this changes status to ACCEPTED after Midtrans callback
	if err := h.usecase.UpdateRegistrationStatus(c.Context(), id, "ACCEPTED"); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "failed to update status: " + err.Error()})
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "Payment successful. Status is now ACCEPTED"})
}

func (h *SpmbHandler) ApproveRegistration(c *fiber.Ctx) error {
	return c.Status(fiber.StatusNotImplemented).JSON(fiber.Map{"message": "ApproveRegistration endpoint stub"})
}

func (h *SpmbHandler) ReRegister(c *fiber.Ctx) error {
	return c.Status(fiber.StatusNotImplemented).JSON(fiber.Map{"message": "ReRegister endpoint stub"})
}
