package domain

import (
	"context"
	"time"

	"github.com/google/uuid"
)

// ChatRoom represents a communication channel between two or more users.
type ChatRoom struct {
	ID        uuid.UUID `json:"id"`
	TenantID  uuid.UUID `json:"tenant_id"`
	Type      string    `json:"type"` // DIRECT, GROUP
	CreatedAt time.Time `json:"created_at"`
}

// ChatMessage represents an encrypted message in a chat room.
type ChatMessage struct {
	ID         uuid.UUID `json:"id"`
	RoomID     uuid.UUID `json:"room_id"`
	SenderID   uuid.UUID `json:"sender_id"`
	Ciphertext string    `json:"ciphertext"` // Encrypted with recipient's public key
	SentAt     time.Time `json:"sent_at"`
}

// RoomSummary represents a chat room in the list of conversations.
type RoomSummary struct {
	RoomID          uuid.UUID `json:"room_id"`
	ParticipantName string    `json:"participant_name"`
	ParticipantID   uuid.UUID `json:"participant_id"`
	Role            string    `json:"role"`
	IsOnline        bool      `json:"is_online"`
	LastMessage     string    `json:"last_message"`
	LastMessageAt   time.Time `json:"last_message_at"`
	UnreadCount     int       `json:"unread_count"`
	PublicKey       string    `json:"public_key"`
}

// ChatContact represents a user that can be messaged.
type ChatContact struct {
	ID        uuid.UUID `json:"id"`
	Name      string    `json:"name"`
	Category  string    `json:"category"`
	ClassName string    `json:"class_name,omitempty"`
	PublicKey string    `json:"public_key,omitempty"` // For Client-side E2EE
}

// ContactListResponse groups contacts for frontend display.
type ContactListResponse struct {
	Students []*ChatContact `json:"students"`
	Parents  []*ChatContact `json:"parents"`
	Staff    []*ChatContact `json:"staff"`
}

type CommunicationRepository interface {
	CreateRoom(ctx context.Context, room *ChatRoom) error
	AddParticipant(ctx context.Context, roomID, userID uuid.UUID) error
	GetDirectRoom(ctx context.Context, user1, user2 uuid.UUID) (*ChatRoom, error)
	GetRoomSummaries(ctx context.Context, tenantID, userID uuid.UUID) ([]*RoomSummary, error)
	
	SaveMessage(ctx context.Context, msg *ChatMessage) error
	GetMessagesByRoomID(ctx context.Context, roomID uuid.UUID) ([]*ChatMessage, error)

	GetContactsForParent(ctx context.Context, tenantID, parentID uuid.UUID) (*ContactListResponse, error)
	
	UpdatePresence(ctx context.Context, userID uuid.UUID, isOnline bool) error
}

type CommunicationUsecase interface {
	InitiateDirectChat(ctx context.Context, tenantID, senderID, receiverID uuid.UUID) (*RoomSummary, error)
	GetRoomSummaries(ctx context.Context, tenantID, userID uuid.UUID) ([]*RoomSummary, error)
	GetMessagesByRoomID(ctx context.Context, roomID uuid.UUID) ([]*ChatMessage, error)
	GetContacts(ctx context.Context, tenantID, userID uuid.UUID, role string) (*ContactListResponse, error)
	SaveMessage(ctx context.Context, roomID, senderID uuid.UUID, ciphertext string) (*ChatMessage, error)
}
