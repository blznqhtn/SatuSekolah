package handlers

import (
	"github.com/gofiber/fiber/v2"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/core/requests"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/core/services"
	"neuracakrawira.asia/satu-sekolah-backend/pkg/validator"
)

type tenantHandler struct {
	service   services.TenantService
	validator *validator.GoPlaygroundValidator
}

func NewTenantHandler(service services.TenantService, validator *validator.GoPlaygroundValidator) TenantHandler {
	return &tenantHandler{service: service, validator: validator}
}

func (h *tenantHandler) CreateTenant(c *fiber.Ctx) error {
	var req requests.CreateTenantRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": true,
			"msg":   err.Error(),
		})
	}

	if err := h.validator.Validate(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": true,
			"msg":   err.Error(),
		})
	}

	tenant, err := h.service.CreateTenant(c.Context(), &req)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": true,
			"msg":   err.Error(),
		})
	}

	return c.Status(fiber.StatusCreated).JSON(tenant)
}

func (h *tenantHandler) GetTenantByID(c *fiber.Ctx) error {
	id := c.Params("id")
	tenant, err := h.service.GetTenantByID(c.Context(), id)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": true,
			"msg":   err.Error(),
		})
	}

	if tenant == nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"error": true,
			"msg":   "tenant not found",
		})
	}

	return c.JSON(tenant)
}
