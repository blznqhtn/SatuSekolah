// Package usecase implements the business logic for the communication module.
//
// ============================================================
//  TRUE END-TO-END ENCRYPTION (E2EE) ARCHITECTURE
// ============================================================
// This backend is a PURE MESSAGE COURIER. It does NOT encrypt
// or decrypt any chat messages. The responsibility is entirely
// on the Frontend/Mobile client.
//
// HOW IT WORKS (WhatsApp/Signal model):
//   1. On first login on a new device, the client generates an
//      RSA or X25519 key-pair locally on the device.
//   2. The client uploads its PUBLIC KEY to the server via:
//         PUT /api/v1/users/profile/public-key
//   3. When a user opens a contact list (GET /communication/contacts),
//      the server returns each contact's public_key.
//   4. Before sending a message, the SENDER (client) encrypts
//      the message content using the RECIPIENT'S public key.
//   5. The resulting ciphertext is sent to the server via WebSocket.
//   6. The server stores the ciphertext as-is and broadcasts it.
//   7. Only the recipient (who holds the private key on their device)
//      can decrypt the message.
//   8. The server, even if compromised, sees ONLY opaque ciphertext.
// ============================================================
package usecase

import (
	"context"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/communication/domain"
)

type communicationUsecase struct {
	repo domain.CommunicationRepository
}

func NewCommunicationUsecase(repo domain.CommunicationRepository) *communicationUsecase {
	return &communicationUsecase{repo: repo}
}

func (u *communicationUsecase) CreateRoom(ctx context.Context, room *domain.ChatRoom) error {
	return u.repo.CreateRoom(ctx, room)
}

func (u *communicationUsecase) GetRoomByID(ctx context.Context, roomID uuid.UUID) (*domain.ChatRoom, error) {
	return u.repo.GetRoomByID(ctx, roomID)
}

func (u *communicationUsecase) GetRoomsByUserID(ctx context.Context, userID uuid.UUID) ([]*domain.ChatRoom, error) {
	return u.repo.GetRoomsByUserID(ctx, userID)
}

// SaveMessage stores the client-encrypted ciphertext verbatim.
// The backend does NOT encrypt, decrypt, or inspect message content.
func (u *communicationUsecase) SaveMessage(ctx context.Context, roomID, senderID uuid.UUID, ciphertext string) (*domain.ChatMessage, error) {
	msg := &domain.ChatMessage{
		RoomID:     roomID,
		SenderID:   senderID,
		Ciphertext: ciphertext, // Stored as-is; encrypted by sender on their device
	}
	err := u.repo.SaveMessage(ctx, msg)
	return msg, err
}

// GetMessages returns raw (client-encrypted) ciphertext messages.
// The frontend client is responsible for decrypting using its private key.
func (u *communicationUsecase) GetMessages(ctx context.Context, roomID uuid.UUID) ([]*domain.ChatMessage, error) {
	return u.repo.GetMessagesByRoomID(ctx, roomID)
}

func (u *communicationUsecase) GetContacts(ctx context.Context, tenantID, userID uuid.UUID, category string) (*domain.ContactListResponse, error) {
	rawContacts, err := u.repo.GetContacts(ctx, tenantID, userID, category)
	if err != nil {
		return nil, err
	}

	response := &domain.ContactListResponse{
		Students: make([]*domain.ChatContact, 0),
		Parents:  make([]*domain.ChatContact, 0),
		Staff:    make([]*domain.ChatContact, 0),
	}

	for _, c := range rawContacts {
		switch c.Category {
		case "student":
			response.Students = append(response.Students, c)
		case "parent":
			response.Parents = append(response.Parents, c)
		case "staff", "admin":
			response.Staff = append(response.Staff, c)
		}
	}

	return response, nil
}
