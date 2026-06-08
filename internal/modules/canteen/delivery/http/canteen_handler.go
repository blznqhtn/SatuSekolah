package http

import (
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/middleware"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/canteen/domain"
)

type CanteenHandler struct {
	uc domain.CanteenUsecase
}

func NewCanteenHandler(uc domain.CanteenUsecase) *CanteenHandler {
	return &CanteenHandler{uc: uc}
}

// POST /api/v1/canteen/shop — Owner creates their shop
func (h *CanteenHandler) CreateShop(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	ownerID, _ := uuid.Parse(claims.UserID)
	tenantID, _ := uuid.Parse(claims.TenantID)

	var body struct {
		Name string `json:"name"`
	}
	if err := c.BodyParser(&body); err != nil || body.Name == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "shop name is required"})
	}

	shop, err := h.uc.CreateShop(c.Context(), tenantID, ownerID, body.Name)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(fiber.Map{"data": shop})
}

// POST /api/v1/canteen/items — Owner adds a menu item
func (h *CanteenHandler) AddItem(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	ownerID, _ := uuid.Parse(claims.UserID)

	var item domain.CanteenItem
	if err := c.BodyParser(&item); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}
	if item.Name == "" || item.Price <= 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "name and valid price are required"})
	}

	if err := h.uc.AddItem(c.Context(), ownerID, &item); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(fiber.Map{"message": "item added successfully"})
}

// POST /api/v1/canteen/cart — Add item to cart
func (h *CanteenHandler) AddToCart(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	userID, _ := uuid.Parse(claims.UserID)

	var body struct {
		ItemID   string `json:"item_id"`
		Quantity int    `json:"quantity"`
	}
	if err := c.BodyParser(&body); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}
	itemID, err := uuid.Parse(body.ItemID)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid item_id"})
	}

	if err := h.uc.AddToCart(c.Context(), userID, itemID, body.Quantity); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "item added to cart"})
}

// POST /api/v1/canteen/checkout — Checkout cart (PIN required)
func (h *CanteenHandler) Checkout(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	userID, _ := uuid.Parse(claims.UserID)
	tenantID, _ := uuid.Parse(claims.TenantID)

	var body struct {
		PIN            string `json:"pin"`
		IsPreorder     bool   `json:"is_preorder"`
		PreorderDate   string `json:"preorder_date"` // "YYYY-MM-DD"
		PreorderTime   string `json:"preorder_time"` // "HH:MM"
		DeliveryMethod string `json:"delivery_method"` // "PICKUP" or "DELIVERY"
	}
	if err := c.BodyParser(&body); err != nil || body.PIN == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "pin is required"})
	}

	order, err := h.uc.CheckoutCart(c.Context(), tenantID, userID, body.IsPreorder, body.PreorderDate, body.PreorderTime, body.DeliveryMethod, body.PIN)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(fiber.Map{
		"message": "Order placed successfully",
		"data":    order,
	})
}

// POST /api/v1/canteen/pos/order — Cashier creates a POS order
func (h *CanteenHandler) CreatePOSOrder(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	ownerID, _ := uuid.Parse(claims.UserID)

	var body struct {
		Items         []domain.CanteenOrderItem `json:"items"`
		PaymentMethod string                    `json:"payment_method"`
	}
	if err := c.BodyParser(&body); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}
	if len(body.Items) == 0 || body.PaymentMethod == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "items and payment_method are required"})
	}

	order, err := h.uc.CreatePOSOrder(c.Context(), ownerID, body.Items, body.PaymentMethod)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(fiber.Map{
		"message": "POS Order created successfully",
		"data":    order,
	})
}

// POST /api/v1/canteen/pay-dynamic-qr — Buyer pays via Dynamic QR (POS mode)
func (h *CanteenHandler) PayViaDynamicQR(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	buyerID, _ := uuid.Parse(claims.UserID)

	var body struct {
		DynamicQRCode string `json:"dynamic_qr_code"`
		PIN           string `json:"pin"`
	}
	if err := c.BodyParser(&body); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}
	if body.DynamicQRCode == "" || body.PIN == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "dynamic_qr_code and pin are required"})
	}

	order, err := h.uc.PayViaDynamicQR(c.Context(), buyerID, body.DynamicQRCode, body.PIN)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{
		"message": "Payment successful",
		"data":    order,
	})
}

// GET /api/v1/iot/canteen/order/:rfidPaymentCode — IoT device fetches order details before tapping
func (h *CanteenHandler) GetOrderForIoT(c *fiber.Ctx) error {
	code := c.Params("rfidPaymentCode")
	if code == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "rfid payment code is required"})
	}

	order, err := h.uc.GetOrderForIoT(c.Context(), code)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{
		"message": "Order found",
		"data":    order,
	})
}

// POST /api/v1/iot/canteen/pay-rfid — Pay via RFID tap (IoT device)
func (h *CanteenHandler) PayViaRFID(c *fiber.Ctx) error {
	var body struct {
		RFIDPaymentCode string `json:"rfid_payment_code"`
		RFIDTag         string `json:"rfid_tag"`
		PIN             string `json:"pin"`
	}
	if err := c.BodyParser(&body); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}
	if body.RFIDPaymentCode == "" || body.RFIDTag == "" || body.PIN == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "rfid_payment_code, rfid_tag, and pin are required"})
	}

	order, err := h.uc.PayViaRFID(c.Context(), body.RFIDPaymentCode, body.RFIDTag, body.PIN)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(fiber.Map{
		"message": "Payment successful via RFID",
		"data":    order,
	})
}

// PATCH /api/v1/canteen/orders/:id/status — Shop owner updates order status
func (h *CanteenHandler) UpdateOrderStatus(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	ownerID, _ := uuid.Parse(claims.UserID)
	orderID, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid order id"})
	}

	var body struct {
		Status string `json:"status"`
	}
	if err := c.BodyParser(&body); err != nil || body.Status == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "status is required"})
	}

	if err := h.uc.UpdateOrderStatus(c.Context(), ownerID, orderID, body.Status); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "Order status updated to " + body.Status})
}

// POST /api/v1/canteen/discounts — Shop owner adds a discount
func (h *CanteenHandler) AddDiscount(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	ownerID, _ := uuid.Parse(claims.UserID)

	var req domain.CanteenDiscount
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}
	if req.DiscountType == "" || req.Value <= 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "discount_type and valid value are required"})
	}

	if err := h.uc.AddDiscount(c.Context(), ownerID, &req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(fiber.Map{"message": "discount added successfully"})
}

// GET /api/v1/canteen/reports/financial?start=2026-06-01&end=2026-06-30
func (h *CanteenHandler) GetFinancialReport(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	ownerID, _ := uuid.Parse(claims.UserID)

	startDate := c.Query("start")
	endDate := c.Query("end")
	if startDate == "" || endDate == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "start and end date query params are required"})
	}

	reports, err := h.uc.GetFinancialReport(c.Context(), ownerID, startDate, endDate)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	totalGross, totalCost, totalNet := 0.0, 0.0, 0.0
	for _, r := range reports {
		totalGross += r.GrossProfit
		totalCost += r.TotalCost
		totalNet += r.NetProfit
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{
		"data": fiber.Map{
			"daily_reports":      reports,
			"total_gross_profit": totalGross,
			"total_cost":         totalCost,
			"total_net_profit":   totalNet,
			"period":             startDate + " to " + endDate,
		},
	})
}

// GET /api/v1/canteen/reports/insight?month=2026-06
func (h *CanteenHandler) GetAIInsight(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	ownerID, _ := uuid.Parse(claims.UserID)

	month := c.Query("month")
	if month == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "month query param is required (YYYY-MM)"})
	}

	insight, err := h.uc.GenerateAIInsight(c.Context(), ownerID, month)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{
		"data": insight,
	})
}
