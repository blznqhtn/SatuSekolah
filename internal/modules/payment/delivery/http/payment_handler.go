package http

import (
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/middleware"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/payment/domain"
)

type PaymentHandler struct {
	usecase domain.PaymentUsecase
}

func NewPaymentHandler(usecase domain.PaymentUsecase) *PaymentHandler {
	return &PaymentHandler{usecase: usecase}
}

func (h *PaymentHandler) GetActiveBills(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)
	userID, _ := uuid.Parse(claims.UserID)

	// If there's a child_id query param (for parents checking their child's bills)
	studentIDStr := c.Query("child_id")
	if studentIDStr != "" {
		parsed, err := uuid.Parse(studentIDStr)
		if err == nil {
			userID = parsed
		}
	}

	bills, err := h.usecase.GetActiveBills(c.Context(), tenantID, userID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	if bills == nil {
		bills = []*domain.PaymentBill{}
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{"data": bills})
}

func (h *PaymentHandler) GetTransactions(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)
	userID, _ := uuid.Parse(claims.UserID)

	studentIDStr := c.Query("child_id")
	if studentIDStr != "" {
		parsed, err := uuid.Parse(studentIDStr)
		if err == nil {
			userID = parsed
		}
	}

	trxs, err := h.usecase.GetTransactions(c.Context(), tenantID, userID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	if trxs == nil {
		trxs = []*domain.PaymentTransaction{}
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{"data": trxs})
}

type payRequest struct {
	BillID        string  `json:"bill_id"`
	ChildID       string  `json:"child_id"`
	Amount        float64 `json:"amount"`
	Pin           string  `json:"pin"`
	PaymentMethod string  `json:"payment_method"`
}

func (h *PaymentHandler) PayBill(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)
	userID, _ := uuid.Parse(claims.UserID)

	var req payRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid payload"})
	}

	if req.ChildID != "" {
		parsed, err := uuid.Parse(req.ChildID)
		if err == nil {
			userID = parsed
		}
	}

	billID, err := uuid.Parse(req.BillID)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid bill ID"})
	}

	if req.PaymentMethod == "" {
		req.PaymentMethod = "IN_APP_WALLET"
	}

	err = h.usecase.PayBill(c.Context(), tenantID, userID, billID, req.Amount, req.PaymentMethod, req.Pin)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "Payment successful"})
}
