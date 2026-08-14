package http

import (
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/middleware"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/communication/domain"
)

type CommunicationHandler struct {
	uc domain.CommunicationUsecase
}

func NewCommunicationHandler(uc domain.CommunicationUsecase) *CommunicationHandler {
	return &CommunicationHandler{uc: uc}
}

// GET /api/v1/communication/contacts
func (h *CommunicationHandler) GetContacts(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)
	userID, _ := uuid.Parse(claims.UserID)
	role := claims.Role // Expected "parent"

	contacts, err := h.uc.GetContacts(c.Context(), tenantID, userID, role)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"data": contacts})
}

// GET /api/v1/communication/rooms
func (h *CommunicationHandler) GetRoomSummaries(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)
	userID, _ := uuid.Parse(claims.UserID)

	rooms, err := h.uc.GetRoomSummaries(c.Context(), tenantID, userID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"data": rooms})
}

// POST /api/v1/communication/rooms/initiate
// Body: { "receiver_id": "uuid" }
func (h *CommunicationHandler) InitiateRoom(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)
	senderID, _ := uuid.Parse(claims.UserID)

	var req struct {
		ReceiverID string `json:"receiver_id"`
	}
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid body"})
	}

	receiverID, err := uuid.Parse(req.ReceiverID)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid receiver_id"})
	}

	roomSummary, err := h.uc.InitiateDirectChat(c.Context(), tenantID, senderID, receiverID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"data": roomSummary})
}

// GET /api/v1/communication/rooms/:roomId/messages
func (h *CommunicationHandler) GetMessages(c *fiber.Ctx) error {
	roomID, err := uuid.Parse(c.Params("roomId"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid room id"})
	}

	messages, err := h.uc.GetMessagesByRoomID(c.Context(), roomID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"data": messages})
}
