package http

import (
	"crypto/sha512"
	"encoding/hex"
	"strconv"
	"strings"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"github.com/midtrans/midtrans-go"
	"github.com/midtrans/midtrans-go/snap"
	aiDomain "neuracakrawira.asia/satu-sekolah-backend/internal/modules/ai/domain"
	"neuracakrawira.asia/satu-sekolah-backend/internal/config"
)

type AIHandler struct {
	repo             aiDomain.AIRepository
	pricePerMillion  int64
	serverKey        string
}

func NewAIHandler(repo aiDomain.AIRepository, cfg *config.Config) *AIHandler {
	// Configure Midtrans Global Environment
	if cfg.Midtrans.IsProduction {
		midtrans.Environment = midtrans.Production
	} else {
		midtrans.Environment = midtrans.Sandbox
	}
	midtrans.ServerKey = cfg.Midtrans.ServerKey

	return &AIHandler{
		repo:            repo,
		pricePerMillion: cfg.Midtrans.PricePerMillionToken,
		serverKey:       cfg.Midtrans.ServerKey,
	}
}

// GetQuota returns the current AI token quota for a tenant
func (h *AIHandler) GetQuota(c *fiber.Ctx) error {
	tenantIDStr := c.Params("tenant_id")
	tenantID, err := uuid.Parse(tenantIDStr)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid tenant_id"})
	}

	quota, err := h.repo.GetQuota(c.Context(), tenantID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	if quota == nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "AI quota not initialized for this tenant"})
	}

	remainingInput := quota.TotalInputTokens - quota.InputTokensUsed
	remainingOutput := quota.TotalOutputTokens - quota.OutputTokensUsed
	return c.JSON(fiber.Map{
		"data": fiber.Map{
			"tenant_id":             quota.TenantID,
			"total_input_tokens":    quota.TotalInputTokens,
			"input_tokens_used":     quota.InputTokensUsed,
			"input_tokens_remaining": remainingInput,
			"total_output_tokens":   quota.TotalOutputTokens,
			"output_tokens_used":    quota.OutputTokensUsed,
			"output_tokens_remaining": remainingOutput,
		},
	})
}

// BuyTokens creates a Midtrans checkout for purchasing AI token packages.
// Each package = 1 million tokens = $10.
// Packages must be >= 1 (minimum 1 million tokens).
func (h *AIHandler) BuyTokens(c *fiber.Ctx) error {
	type BuyTokenRequest struct {
		TenantID string `json:"tenant_id"`
		Packages int    `json:"packages"` // Number of 1M-token packages
	}

	var req BuyTokenRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}

	tenantID, err := uuid.Parse(req.TenantID)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid tenant_id"})
	}

	if req.Packages < 1 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "minimum 1 package (1 million tokens)"})
	}

	totalTokens := int64(req.Packages) * 1_000_000
	totalPriceUSD := int64(req.Packages) * h.pricePerMillion
	// Rough IDR conversion (1 USD = ~15,000 IDR) for Midtrans
	totalPriceIDR := totalPriceUSD * 15_000

	// Generate unique Order ID
	orderID := "AI-TOKENS-" + tenantID.String() + "-" + uuid.New().String()[:8]

	// Create Midtrans Snap Request
	snapReq := &snap.Request{
		TransactionDetails: midtrans.TransactionDetails{
			OrderID:  orderID,
			GrossAmt: totalPriceIDR,
		},
		Items: &[]midtrans.ItemDetails{
			{
				ID:    "AI_TOKEN_PKG",
				Price: totalPriceIDR / int64(req.Packages),
				Qty:   int32(req.Packages),
				Name:  "Gemini AI Token Package (1M Tokens/pkg)",
			},
		},
		CustomerDetail: &midtrans.CustomerDetails{
			FName: "Tenant",
			LName: tenantID.String(),
		},
	}

	snapResp, snapErr := snap.CreateTransaction(snapReq)
	if snapErr != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to create payment gateway checkout: " + snapErr.Error()})
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{
		"message": "Checkout created successfully",
		"data": fiber.Map{
			"tenant_id":       tenantID,
			"packages":        req.Packages,
			"total_input_added":  totalTokens,
			"total_output_added": totalTokens,
			"price_usd":       totalPriceUSD,
			"price_idr":       totalPriceIDR,
			"price_formatted": "Rp " + formatNumber(totalPriceIDR),
			"order_id":        orderID,
			"snap_token":      snapResp.Token,
			"snap_url":        snapResp.RedirectURL,
		},
	})
}

// WebhookTokenPurchase processes the Midtrans callback after successful payment.
// In production, validate the Midtrans signature before processing.
func (h *AIHandler) WebhookTokenPurchase(c *fiber.Ctx) error {
	type WebhookPayload struct {
		OrderID           string `json:"order_id"`
		StatusCode        string `json:"status_code"`
		GrossAmount       string `json:"gross_amount"`
		SignatureKey      string `json:"signature_key"`
		TransactionStatus string `json:"transaction_status"`
	}

	var payload WebhookPayload
	if err := c.BodyParser(&payload); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid webhook payload"})
	}

	// 1. Verify Signature
	// signature = SHA512(order_id + status_code + gross_amount + server_key)
	rawSignature := payload.OrderID + payload.StatusCode + payload.GrossAmount + h.serverKey
	hash := sha512.New()
	hash.Write([]byte(rawSignature))
	expectedSignature := hex.EncodeToString(hash.Sum(nil))

	if expectedSignature != payload.SignatureKey {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "invalid signature key"})
	}

	if payload.TransactionStatus != "settlement" && payload.TransactionStatus != "capture" {
		return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "transaction not settled/captured, ignoring"})
	}

	// Order ID format: NCS{YYYYMMDD}{random} OR AI-TOKENS-{tenant_id}-{random}
	// Untuk AI Token, tenant_id wajib ada agar tahu siapa yang topup.
	// Kita kembalikan ke format AI-TOKENS agar mudah diekstrak UUID-nya tanpa perlu konek coreRepo.
	parts := strings.Split(payload.OrderID, "-")
	if len(parts) < 4 || parts[0] != "AI" || parts[1] != "TOKENS" {
		return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "not an ai token order, ignoring"})
	}

	tenantIDStr := parts[2]
	for i := 3; i < len(parts)-1; i++ {
		tenantIDStr += "-" + parts[i]
	}

	tenantID, err := uuid.Parse(tenantIDStr)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid tenant_id in order_id"})
	}

	// Calculate packages from gross_amount
	grossAmt, _ := strconv.ParseFloat(payload.GrossAmount, 64)
	pricePerPkgIDR := float64(h.pricePerMillion * 15_000)
	packages := int(grossAmt / pricePerPkgIDR)

	if packages < 1 {
		return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "no valid packages calculated"})
	}

	addTokens := int64(packages) * 1_000_000

	if err := h.repo.ExecTx(c.Context(), func(txRepo aiDomain.AIRepository) error {
		return txRepo.TopupQuota(c.Context(), tenantID, addTokens, addTokens)
	}); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "failed to topup quota: " + err.Error()})
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{
		"message":             "AI token quota successfully topped up",
		"input_tokens_added":  addTokens,
		"output_tokens_added": addTokens,
	})
}

func formatNumber(n int64) string {
	s := strconv.FormatInt(n, 10)
	if len(s) <= 3 {
		return s
	}
	result := ""
	for i, c := range s {
		if i > 0 && (len(s)-i)%3 == 0 {
			result += "."
		}
		result += string(c)
	}
	return result
}
