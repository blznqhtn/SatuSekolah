package http

import (
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/middleware"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/inventory/domain"
)

type InventoryHandler struct {
	usecase domain.InventoryUsecase
}

func NewInventoryHandler(usecase domain.InventoryUsecase) *InventoryHandler {
	return &InventoryHandler{usecase: usecase}
}

func (h *InventoryHandler) GetInventories(c *fiber.Ctx) error {
	claims, ok := c.Locals("claims").(*middleware.Claims)
	if !ok || claims == nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "unauthorized"})
	}

	tenantID, err := uuid.Parse(claims.TenantID)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid tenant_id"})
	}

	items, err := h.usecase.GetItems(c.Context(), tenantID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(fiber.Map{
		"data": items,
	})
}

func (h *InventoryHandler) CreateItem(c *fiber.Ctx) error {
	claims, ok := c.Locals("claims").(*middleware.Claims)
	if !ok || claims == nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "unauthorized"})
	}

	var req struct {
		Name        string `json:"name"`
		Description string `json:"description"`
		Stock       int    `json:"stock"`
		Condition   string `json:"condition"`
	}

	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}

	tenantID, _ := uuid.Parse(claims.TenantID)

	item := &domain.InventoryItem{
		TenantID:    tenantID,
		Name:        req.Name,
		Description: req.Description,
		Stock:       req.Stock,
		Condition:   req.Condition,
	}

	if item.Condition == "" {
		item.Condition = "GOOD"
	}

	if err := h.usecase.CreateItem(c.Context(), item); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusCreated).JSON(fiber.Map{
		"message": "Item created successfully",
		"data":    item,
	})
}

func (h *InventoryHandler) ReportCondition(c *fiber.Ctx) error {
	claims, ok := c.Locals("claims").(*middleware.Claims)
	if !ok || claims == nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "unauthorized"})
	}

	itemID, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid item_id"})
	}

	var req struct {
		Condition   string `json:"condition"`
		Stock       int    `json:"stock"`
		Notes       string `json:"notes"`
		DocumentURL string `json:"document_url"`
	}

	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}

	tenantID, _ := uuid.Parse(claims.TenantID)
	staffID, _ := uuid.Parse(claims.UserID)

	report := &domain.InventoryReport{
		TenantID:    tenantID,
		ItemID:      itemID,
		StaffID:     staffID,
		Condition:   req.Condition,
		Notes:       req.Notes,
		DocumentURL: req.DocumentURL,
	}

	if err := h.usecase.ReportCondition(c.Context(), report, req.Stock); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(fiber.Map{
		"message": "Report submitted successfully",
	})
}
