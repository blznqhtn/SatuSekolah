package ws

import (
	"context"
	"encoding/json"
	"log"
	"sync"
	"time"

	"github.com/gofiber/websocket/v2"
	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/middleware"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/communication/domain"
)

// Hub maintains the set of active clients and broadcasts messages to the rooms.
type Hub struct {
	// Registered clients map. room_id -> map[client]bool
	rooms map[string]map[*Client]bool

	// Inbound messages from the clients.
	broadcast chan *MessageEvent

	// Register requests from the clients.
	register chan *Client

	// Unregister requests from clients.
	unregister chan *Client

	// mu guards rooms map
	mu sync.RWMutex

	// JWT secret for WebSocket payload auth
	jwtSecret string

	// Dependency to save messages
	usecase interface {
		SaveMessage(ctx context.Context, roomID, senderID uuid.UUID, ciphertext string) (*domain.ChatMessage, error)
	}
}

// Client is a middleman between the websocket connection and the hub.
type Client struct {
	hub *Hub

	// The websocket connection.
	conn *websocket.Conn

	// The ID of the user connected.
	userID uuid.UUID

	// The room they are connected to.
	roomID string

	// Whether this client has been authenticated via payload auth
	authenticated bool
}

// MessageEvent is the JSON payload sent/received over websocket.
type MessageEvent struct {
	// Type: "auth" for auth handshake, "message" for chat messages
	Type     string `json:"type"`
	RoomID   string `json:"room_id"`
	SenderID string `json:"sender_id"`
	Content  string `json:"content"`            // Client-encrypted ciphertext
	SentAt   string `json:"sent_at,omitempty"`
	// Auth fields (used only when Type == "auth")
	Token    string `json:"token,omitempty"`
}

func NewHub(jwtSecret string, usecase interface {
	SaveMessage(ctx context.Context, roomID, senderID uuid.UUID, ciphertext string) (*domain.ChatMessage, error)
}) *Hub {
	return &Hub{
		rooms:      make(map[string]map[*Client]bool),
		broadcast:  make(chan *MessageEvent),
		register:   make(chan *Client),
		unregister: make(chan *Client),
		jwtSecret:  jwtSecret,
		usecase:    usecase,
	}
}

func (h *Hub) Run() {
	for {
		select {
		case client := <-h.register:
			h.mu.Lock()
			if h.rooms[client.roomID] == nil {
				h.rooms[client.roomID] = make(map[*Client]bool)
			}
			h.rooms[client.roomID][client] = true
			h.mu.Unlock()

		case client := <-h.unregister:
			h.mu.Lock()
			if clients, ok := h.rooms[client.roomID]; ok {
				if _, ok := clients[client]; ok {
					delete(clients, client)
					client.conn.Close()
					if len(clients) == 0 {
						delete(h.rooms, client.roomID)
					}
				}
			}
			h.mu.Unlock()

		case message := <-h.broadcast:
			// Save to DB via usecase (stores ciphertext as-is)
			roomUUID, _ := uuid.Parse(message.RoomID)
			senderUUID, _ := uuid.Parse(message.SenderID)

			_, err := h.usecase.SaveMessage(context.Background(), roomUUID, senderUUID, message.Content)
			if err != nil {
				log.Printf("[WS] Failed to save message: %v\n", err)
				continue
			}

			// Broadcast to all clients in the room
			message.SentAt = time.Now().Format(time.RFC3339)
			payload, _ := json.Marshal(message)

			h.mu.RLock()
			for client := range h.rooms[message.RoomID] {
				if !client.authenticated {
					continue // Never relay to unauthenticated clients
				}
				err := client.conn.WriteMessage(websocket.TextMessage, payload)
				if err != nil {
					client.conn.Close()
				}
			}
			h.mu.RUnlock()
		}
	}
}

// ReadPump reads messages from the WS connection.
// The FIRST message MUST be a JSON payload with type="auth" and a valid JWT token.
// Any subsequent message is treated as a chat message.
func (c *Client) ReadPump() {
	defer func() {
		c.hub.unregister <- c
		c.conn.Close()
	}()

	// Set a tight deadline for the auth handshake (10 seconds)
	c.conn.SetReadDeadline(time.Now().Add(10 * time.Second))

	// --- STEP 1: Wait for auth payload ---
	_, rawPayload, err := c.conn.ReadMessage()
	if err != nil {
		log.Printf("[WS] Auth read failed: %v", err)
		return
	}

	var authMsg MessageEvent
	if err := json.Unmarshal(rawPayload, &authMsg); err != nil || authMsg.Type != "auth" || authMsg.Token == "" {
		log.Printf("[WS] Invalid auth payload; closing connection")
		c.conn.WriteMessage(websocket.TextMessage, []byte(`{"error":"first message must be {\"type\":\"auth\",\"token\":\"...\"}","code":4001}`))
		return
	}

	// Validate JWT
	claims := &middleware.Claims{}
	token, err := jwt.ParseWithClaims(authMsg.Token, claims, func(t *jwt.Token) (interface{}, error) {
		if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, jwt.ErrSignatureInvalid
		}
		return []byte(c.hub.jwtSecret), nil
	})
	if err != nil || !token.Valid {
		log.Printf("[WS] WS auth failed: invalid token")
		c.conn.WriteMessage(websocket.TextMessage, []byte(`{"error":"invalid or expired token","code":4003}`))
		return
	}

	// Auth success
	c.userID, _ = uuid.Parse(claims.UserID)
	c.authenticated = true
	// Remove deadline — connection is now authenticated
	c.conn.SetReadDeadline(time.Time{})
	c.conn.WriteMessage(websocket.TextMessage, []byte(`{"type":"auth_ok"}`))

	log.Printf("[WS] Client %s authenticated in room %s", c.userID, c.roomID)

	// --- STEP 2: Normal message loop ---
	for {
		_, payload, err := c.conn.ReadMessage()
		if err != nil {
			if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
				log.Printf("[WS] read error: %v", err)
			}
			break
		}

		var msgEvent MessageEvent
		if err := json.Unmarshal(payload, &msgEvent); err == nil {
			msgEvent.Type = "message"
			msgEvent.RoomID = c.roomID
			msgEvent.SenderID = c.userID.String()
			c.hub.broadcast <- &msgEvent
		}
	}
}
