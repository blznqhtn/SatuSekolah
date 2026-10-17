package http

import (
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/config"
	"neuracakrawira.asia/satu-sekolah-backend/internal/middleware"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/finance/domain"
)

type LedgerHandler struct {
	usecase    domain.LedgerUsecase
	clientKey  string
}

func NewLedgerHandler(usecase domain.LedgerUsecase, cfg *config.Config) *LedgerHandler {
	return &LedgerHandler{
		usecase:   usecase,
		clientKey: cfg.Midtrans.ClientKey,
	}
}

func (h *LedgerHandler) RecordTransaction(c *fiber.Ctx) error {
	var req domain.WalletLedger
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}

	ledger, err := h.usecase.RecordTransaction(c.Context(), &req)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusCreated).JSON(fiber.Map{
		"message": "Transaction securely recorded in Web3 Ledger",
		"data":    ledger,
	})
}

// GetTransactionHistory returns the full wallet ledger for the authenticated user.
// Frontend can use this data to generate a downloadable PDF report.
func (h *LedgerHandler) GetTransactionHistory(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	userID, _ := uuid.Parse(claims.UserID)
	tenantID, _ := uuid.Parse(claims.TenantID)

	ledgers, err := h.usecase.GetTransactionHistory(c.Context(), tenantID, userID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{
		"user_id": userID,
		"data":    ledgers,
	})
}

// GetMidtransClientKey returns the safe-to-expose Midtrans client key for frontend.
func (h *LedgerHandler) GetMidtransClientKey(c *fiber.Ctx) error {
	return c.Status(fiber.StatusOK).JSON(fiber.Map{
		"client_key": h.clientKey,
	})
}

// POST /api/v1/finance/transfer — P2P Transfer (including Canteen VA)
func (h *LedgerHandler) TransferP2P(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	senderID, _ := uuid.Parse(claims.UserID)
	tenantID, _ := uuid.Parse(claims.TenantID)

	var body struct {
		TargetAccountNumber string  `json:"target_account_number"`
		Amount              float64 `json:"amount"`
		PIN                 string  `json:"pin"`
	}
	if err := c.BodyParser(&body); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}

	if body.TargetAccountNumber == "" || body.Amount <= 0 || body.PIN == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "target_account_number, amount, and pin are required"})
	}

	err := h.usecase.TransferP2P(c.Context(), tenantID, senderID, body.TargetAccountNumber, body.Amount, body.PIN)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{
		"message": "Transfer successful",
	})
}
