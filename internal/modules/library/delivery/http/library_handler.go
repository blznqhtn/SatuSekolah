package http

import (
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/middleware"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/library/domain"
)

type LibraryHandler struct {
	uc domain.LibraryUsecase
}

func NewLibraryHandler(uc domain.LibraryUsecase) *LibraryHandler {
	return &LibraryHandler{uc: uc}
}

// Stubs for brevity, but shows the new routes
func (h *LibraryHandler) AddBook(c *fiber.Ctx) error {
	return c.SendStatus(fiber.StatusNotImplemented)
}

func (h *LibraryHandler) RequestBorrow(c *fiber.Ctx) error {
	return c.SendStatus(fiber.StatusNotImplemented)
}

func (h *LibraryHandler) ApproveBorrow(c *fiber.Ctx) error {
	return c.SendStatus(fiber.StatusNotImplemented)
}

func (h *LibraryHandler) ScanBorrowQR(c *fiber.Ctx) error {
	return c.SendStatus(fiber.StatusNotImplemented)
}

func (h *LibraryHandler) ReturnScanCheck(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	staffID, _ := uuid.Parse(claims.UserID)

	type req struct {
		BorrowingID string `json:"borrowing_id"`
	}
	var body req
	if err := c.BodyParser(&body); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}
	borrowingID, _ := uuid.Parse(body.BorrowingID)

	fee, requiresPIN, staffAccountNumber, err := h.uc.CheckReturnScan(c.Context(), borrowingID, staffID)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	if requiresPIN {
		return c.Status(fiber.StatusOK).JSON(fiber.Map{
			"status":                 "REQUIRE_PIN",
			"fee_amount":             fee,
			"destination_account":    staffAccountNumber,
			"message":                "Late fee applies. Enter your PIN to complete return.",
			"borrowing_id":           borrowingID,
		})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"status": "RETURNED", "message": "Book returned successfully."})
}

func (h *LibraryHandler) ReturnScanConfirm(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	staffID, _ := uuid.Parse(claims.UserID)

	type req struct {
		BorrowingID string `json:"borrowing_id"`
		PIN         string `json:"pin"`
	}
	var body req
	if err := c.BodyParser(&body); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}
	borrowingID, _ := uuid.Parse(body.BorrowingID)

	err := h.uc.ConfirmReturnScan(c.Context(), borrowingID, staffID, body.PIN)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"status": "RETURNED", "message": "Book returned successfully with late fee paid."})
}

func (h *LibraryHandler) PurchaseDigitalBook(c *fiber.Ctx) error {
	return c.SendStatus(fiber.StatusNotImplemented)
}

func (h *LibraryHandler) UploadJournal(c *fiber.Ctx) error {
	return c.SendStatus(fiber.StatusNotImplemented)
}

func (h *LibraryHandler) ApproveJournal(c *fiber.Ctx) error {
	return c.SendStatus(fiber.StatusNotImplemented)
}

func (h *LibraryHandler) ConfigureSetting(c *fiber.Ctx) error {
	return c.SendStatus(fiber.StatusNotImplemented)
}
