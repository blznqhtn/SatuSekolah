package ws

import (
	"context"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/websocket/v2"
	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/middleware"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/communication/domain"
)

type communicationUsecase interface {
	GetRoomByID(ctx context.Context, roomID uuid.UUID) (*domain.ChatRoom, error)
	GetMessages(ctx context.Context, roomID uuid.UUID) ([]*domain.ChatMessage, error)
	SaveMessage(ctx context.Context, roomID, senderID uuid.UUID, ciphertext string) (*domain.ChatMessage, error)
	GetContacts(ctx context.Context, tenantID, userID uuid.UUID, category string) (*domain.ContactListResponse, error)
}

type CommunicationHandler struct {
	usecase communicationUsecase
	hub     *Hub
}

func NewCommunicationHandler(usecase communicationUsecase, hub *Hub) *CommunicationHandler {
	return &CommunicationHandler{
		usecase: usecase,
		hub:     hub,
	}
}

// WebsocketUpgradeMiddleware checks that the request is a valid WS upgrade.
// Authentication is NO LONGER done here — it is done inside the WS connection
// via the first message payload (see ws_hub.go ReadPump).
func WebsocketUpgradeMiddleware() fiber.Handler {
	return func(c *fiber.Ctx) error {
		if !websocket.IsWebSocketUpgrade(c) {
			return fiber.ErrUpgradeRequired
		}
		return c.Next()
	}
}

// HandleChatRoom handles the WS connection.
// Auth is handled inside ReadPump via the first JSON message.
func (h *CommunicationHandler) HandleChatRoom(c *websocket.Conn) {
	roomID := c.Params("room_id")

	client := &Client{
		hub:           h.hub,
		conn:          c,
		roomID:        roomID,
		authenticated: false,
	}

	client.hub.register <- client

	// ReadPump blocks until connection closes.
	// The first thing ReadPump does is wait for auth payload.
	client.ReadPump()
}

// GetChatHistory returns the raw (client-encrypted) ciphertext messages for a room.
// The frontend is responsible for decrypting them using the recipient's private key.
func (h *CommunicationHandler) GetChatHistory(c *fiber.Ctx) error {
	roomIDStr := c.Params("room_id")
	roomID, err := uuid.Parse(roomIDStr)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid room ID"})
	}

	messages, err := h.usecase.GetMessages(c.Context(), roomID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(fiber.Map{
		"data": messages,
		"note": "Messages are client-encrypted ciphertext. Decrypt using the recipient's private key on the device.",
	})
}

// GetContacts returns the list of allowed contacts for the logged-in user.
// Each contact includes their public_key for client-side E2EE.
func (h *CommunicationHandler) GetContacts(c *fiber.Ctx) error {
	claims, ok := c.Locals("claims").(*middleware.Claims)
	if !ok || claims == nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "unauthorized"})
	}

	userID, err := uuid.Parse(claims.UserID)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid user_id"})
	}
	tenantID, err := uuid.Parse(claims.TenantID)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid tenant_id"})
	}

	contacts, err := h.usecase.GetContacts(c.Context(), tenantID, userID, claims.Role)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(fiber.Map{
		"data": contacts,
	})
}
