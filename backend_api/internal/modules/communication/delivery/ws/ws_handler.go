package ws

import (
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/websocket/v2"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/communication/domain"
)

type CommunicationWsHandler struct {
	usecase domain.CommunicationUsecase
	hub     *Hub
}

func NewCommunicationWsHandler(usecase domain.CommunicationUsecase, hub *Hub) *CommunicationWsHandler {
	return &CommunicationWsHandler{
		usecase: usecase,
		hub:     hub,
	}
}

// WebsocketUpgradeMiddleware checks that the request is a valid WS upgrade.
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
func (h *CommunicationWsHandler) HandleChatRoom(c *websocket.Conn) {
	roomID := c.Params("room_id")

	client := &Client{
		hub:           h.hub,
		conn:          c,
		roomID:        roomID,
		authenticated: false,
	}

	client.hub.register <- client

	// ReadPump blocks until connection closes.
	client.ReadPump()
}
