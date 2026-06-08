package http

import (
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/core/domain"
)

type TenantHandler struct {
	usecase domain.CoreUsecase
}

func NewTenantHandler(usecase domain.CoreUsecase) *TenantHandler {
	return &TenantHandler{usecase: usecase}
}

func (h *TenantHandler) RegisterTenant(c *fiber.Ctx) error {
	var req domain.RegisterTenantRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}

	tenant, err := h.usecase.RegisterNewTenant(c.Context(), &req)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusCreated).JSON(fiber.Map{
		"message": "Tenant and Admin successfully created",
		"data":    tenant,
	})
}

func (h *TenantHandler) GetTenantProfile(c *fiber.Ctx) error {
	idParam := c.Params("id")
	id, err := uuid.Parse(idParam)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid UUID format"})
	}

	tenant, err := h.usecase.GetTenantProfile(c.Context(), id)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	if tenant == nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "tenant not found"})
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{"data": tenant})
}

func (h *TenantHandler) GetPermissions(c *fiber.Ctx) error {
	perms, err := h.usecase.GetSystemPermissions(c.Context())
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(perms)
}
