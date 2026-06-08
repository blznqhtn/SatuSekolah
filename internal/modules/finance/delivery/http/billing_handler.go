package http

import (
	"crypto/sha512"
	"encoding/hex"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/config"
	"neuracakrawira.asia/satu-sekolah-backend/internal/middleware"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/finance/domain"
)

// BillingHandler menangani semua endpoint terkait tagihan sekolah
type BillingHandler struct {
	usecase   domain.BillingUsecase
	serverKey string // Midtrans Server Key untuk verifikasi webhook
}

func NewBillingHandler(usecase domain.BillingUsecase, cfg *config.Config) *BillingHandler {
	return &BillingHandler{
		usecase:   usecase,
		serverKey: cfg.Midtrans.ServerKey,
	}
}

// POST /api/v1/finance/fees/generate
// Role: Admin Keuangan
// Membuat tagihan massal untuk semua siswa target (bisa per kelas, jurusan, atau semua).
// Sistem otomatis menghasilkan QR Dinamis, kode RFID, dan Virtual Account 15 digit per tagihan.
func (h *BillingHandler) GenerateMassInvoices(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)

	var req domain.GenerateInvoiceRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "request tidak valid"})
	}
	if req.InvoiceName == "" || req.Amount <= 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invoice_name dan amount wajib diisi"})
	}

	if err := h.usecase.GenerateMassInvoices(c.Context(), tenantID, req); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusCreated).JSON(fiber.Map{
		"message": "Tagihan berhasil dibuat untuk semua siswa target",
	})
}

// GET /api/v1/finance/invoices?student_id=xxx
// Role: Semua (Siswa lihat tagihan sendiri, Orang Tua bisa pass ?student_id=)
// Menampilkan daftar tagihan beserta QR Code, RFID Code, dan Virtual Account untuk pembayaran.
func (h *BillingHandler) GetMyInvoices(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)
	userID, _ := uuid.Parse(claims.UserID)

	// Orang tua bisa lihat tagihan anaknya
	if studentIDParam := c.Query("student_id"); studentIDParam != "" {
		if parsed, err := uuid.Parse(studentIDParam); err == nil {
			userID = parsed
		}
	}

	invoices, err := h.usecase.GetStudentInvoices(c.Context(), tenantID, userID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{"data": invoices})
}

// POST /api/v1/finance/invoices/pay-dynamic-qr
// Role: Siswa / Orang Tua
// Bayar tagihan dengan scan QR Dinamis. Bisa bayar penuh atau mencicil (jika diizinkan).
// Body: { "dynamic_qr_code": "...", "amount": 500000, "pin": "..." }
func (h *BillingHandler) PayInvoiceDynamicQR(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	payerID, _ := uuid.Parse(claims.UserID)

	var body struct {
		DynamicQRCode string  `json:"dynamic_qr_code"`
		Amount        float64 `json:"amount"`
		PIN           string  `json:"pin"`
	}
	if err := c.BodyParser(&body); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "request tidak valid"})
	}
	if body.DynamicQRCode == "" || body.Amount <= 0 || body.PIN == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "dynamic_qr_code, amount, dan pin wajib diisi"})
	}

	if err := h.usecase.PayInvoiceDynamicQR(c.Context(), payerID, body.DynamicQRCode, body.Amount, body.PIN); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "Pembayaran berhasil"})
}

// GET /api/v1/iot/finance/invoice/:rfidPaymentCode
// Role: Mesin IoT (tanpa JWT)
// Mesin RFID mengambil info tagihan (nama, sisa tagihan) sebelum pembayaran dilakukan.
func (h *BillingHandler) GetInvoiceForIoT(c *fiber.Ctx) error {
	code := c.Params("rfidPaymentCode")
	if code == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "kode RFID tagihan wajib diisi"})
	}

	inv, err := h.usecase.GetInvoiceForIoT(c.Context(), code)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{
		"message": "Tagihan ditemukan",
		"data":    inv,
	})
}

// POST /api/v1/iot/finance/pay-rfid
// Role: Mesin IoT (tanpa JWT)
// Mesin RFID memproses pembayaran setelah siswa tap kartu dan masukkan PIN.
// Body: { "rfid_payment_code": "12345678", "rfid_tag": "ABCDEF", "pin": "...", "amount": 500000 }
func (h *BillingHandler) PayInvoiceRFID(c *fiber.Ctx) error {
	var body struct {
		RFIDPaymentCode string  `json:"rfid_payment_code"`
		RFIDTag         string  `json:"rfid_tag"`
		PIN             string  `json:"pin"`
		Amount          float64 `json:"amount"`
	}
	if err := c.BodyParser(&body); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "request tidak valid"})
	}
	if body.RFIDPaymentCode == "" || body.RFIDTag == "" || body.PIN == "" || body.Amount <= 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "rfid_payment_code, rfid_tag, pin, dan amount wajib diisi",
		})
	}

	if err := h.usecase.PayInvoiceRFID(c.Context(), body.RFIDPaymentCode, body.RFIDTag, body.PIN, body.Amount); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "Pembayaran berhasil via RFID"})
}

// POST /api/v1/finance/invoices/:id/pay-cash
// Role: Admin Keuangan
// Admin keuangan memulai sesi pembayaran tunai via Midtrans Snap.
// Response: { "snap_url": "...", "snap_token": "...", "order_id": "...", "total_amount": ... }
// Biaya admin Rp5.000 ditambahkan ke total untuk biaya gateway.
// Body: { "amount": 500000 } (opsional — default ke sisa tagihan)
func (h *BillingHandler) InitiateCashPayment(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	adminID, _ := uuid.Parse(claims.UserID)

	invoiceID, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "ID tagihan tidak valid"})
	}

	var body struct {
		Amount float64 `json:"amount"`
	}
	c.BodyParser(&body) // opsional

	resp, err := h.usecase.InitiateCashPayment(c.Context(), adminID, invoiceID, body.Amount)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{
		"message": "Sesi pembayaran tunai berhasil dibuat",
		"data":    resp,
	})
}

// POST /api/v1/webhooks/midtrans/invoices
// Role: Midtrans (tidak ada JWT — diverifikasi via HMAC signature)
// Dipanggil otomatis oleh Midtrans setelah pembayaran tunai berhasil.
// Sistem akan mengupdate status tagihan menjadi PARTIAL atau PAID secara otomatis.
func (h *BillingHandler) MidtransWebhook(c *fiber.Ctx) error {
	type WebhookPayload struct {
		OrderID           string `json:"order_id"`
		StatusCode        string `json:"status_code"`
		GrossAmount       string `json:"gross_amount"`
		SignatureKey      string `json:"signature_key"`
		TransactionStatus string `json:"transaction_status"`
	}

	var payload WebhookPayload
	if err := c.BodyParser(&payload); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "payload webhook tidak valid"})
	}

	// Verifikasi signature: SHA512(order_id + status_code + gross_amount + server_key)
	rawSig := payload.OrderID + payload.StatusCode + payload.GrossAmount + h.serverKey
	hash := sha512.New()
	hash.Write([]byte(rawSig))
	expectedSig := hex.EncodeToString(hash.Sum(nil))

	if expectedSig != payload.SignatureKey {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "signature tidak valid"})
	}

	if err := h.usecase.ProcessMidtransWebhook(
		c.Context(),
		payload.OrderID,
		payload.TransactionStatus,
		payload.GrossAmount,
		payload.SignatureKey,
	); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "OK"})
}

// GET /api/v1/finance/reports/invoices?fee_type_id=xxx
// Role: Admin Keuangan
// Laporan rekap tagihan: siapa yang sudah lunas, menyicil, atau belum bayar.
// Setiap baris berisi nama siswa dan NISN untuk identifikasi yang akurat.
func (h *BillingHandler) GetFinanceReport(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)

	var feeTypeID *uuid.UUID
	if feeTypeIDParam := c.Query("fee_type_id"); feeTypeIDParam != "" {
		if parsed, err := uuid.Parse(feeTypeIDParam); err == nil {
			feeTypeID = &parsed
		}
	}

	report, err := h.usecase.GetFinanceReport(c.Context(), tenantID, feeTypeID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{"data": report})
}
