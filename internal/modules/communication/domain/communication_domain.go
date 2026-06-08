package domain

import (
	"context"
	"time"

	"github.com/google/uuid"
)

// ChatRoom represents a communication channel between two or more users.
type ChatRoom struct {
	ID             uuid.UUID `json:"id"`
	TenantID       uuid.UUID `json:"tenant_id"`
	Type           string    `json:"type"` // DIRECT, GROUP
	ParticipantIDs string    `json:"participant_ids"` // JSON array string of user IDs
	CreatedAt      time.Time `json:"created_at"`
	UpdatedAt      time.Time `json:"updated_at"`
}

// ChatMessage represents an encrypted message in a chat room.
type ChatMessage struct {
	ID         uuid.UUID `json:"id"`
	RoomID     uuid.UUID `json:"room_id"`
	SenderID   uuid.UUID `json:"sender_id"`
	Ciphertext string    `json:"ciphertext"` // AES-256-GCM encrypted
	CreatedAt  time.Time `json:"created_at"`
}

// DecryptedMessage represents a message returned to the client.
type DecryptedMessage struct {
	ID        uuid.UUID `json:"id"`
	RoomID    uuid.UUID `json:"room_id"`
	SenderID  uuid.UUID `json:"sender_id"`
	Content   string    `json:"content"` // Decrypted plain text
	CreatedAt time.Time `json:"created_at"`
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
	GetRoomByID(ctx context.Context, roomID uuid.UUID) (*ChatRoom, error)
	GetRoomsByUserID(ctx context.Context, userID uuid.UUID) ([]*ChatRoom, error)
	
	SaveMessage(ctx context.Context, msg *ChatMessage) error
	GetMessagesByRoomID(ctx context.Context, roomID uuid.UUID) ([]*ChatMessage, error)

	GetContacts(ctx context.Context, tenantID, userID uuid.UUID, category string) ([]*ChatContact, error)
}
