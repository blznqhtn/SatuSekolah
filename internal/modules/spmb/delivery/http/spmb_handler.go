package http

import (
	"github.com/gofiber/fiber/v2"
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
	return c.Status(fiber.StatusNotImplemented).JSON(fiber.Map{"message": "RegisterSpmb endpoint stub"})
}

func (h *SpmbHandler) ApproveRegistration(c *fiber.Ctx) error {
	return c.Status(fiber.StatusNotImplemented).JSON(fiber.Map{"message": "ApproveRegistration endpoint stub"})
}

func (h *SpmbHandler) ReRegister(c *fiber.Ctx) error {
	return c.Status(fiber.StatusNotImplemented).JSON(fiber.Map{"message": "ReRegister endpoint stub"})
}
