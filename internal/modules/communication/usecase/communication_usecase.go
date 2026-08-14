package usecase

import (
	"context"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/communication/domain"
)

type communicationUsecase struct {
	repo domain.CommunicationRepository
}

func NewCommunicationUsecase(repo domain.CommunicationRepository) domain.CommunicationUsecase {
	return &communicationUsecase{repo: repo}
}

func (u *communicationUsecase) InitiateDirectChat(ctx context.Context, tenantID, senderID, receiverID uuid.UUID) (*domain.RoomSummary, error) {
	// 1. Check if room exists
	room, err := u.repo.GetDirectRoom(ctx, senderID, receiverID)
	if err != nil {
		return nil, err
	}

	// 2. Create if not exists
	if room == nil {
		newRoom := &domain.ChatRoom{
			TenantID: tenantID,
			Type:     "DIRECT",
		}
		if err := u.repo.CreateRoom(ctx, newRoom); err != nil {
			return nil, err
		}
		room = newRoom
		
		// Add participants
		if err := u.repo.AddParticipant(ctx, room.ID, senderID); err != nil {
			return nil, err
		}
		if err := u.repo.AddParticipant(ctx, room.ID, receiverID); err != nil {
			return nil, err
		}
	}

	// 3. Return summary (we could fetch from DB, but since we just initiated, we can mock or fetch it properly)
	summaries, err := u.repo.GetRoomSummaries(ctx, tenantID, senderID)
	if err != nil {
		return nil, err
	}
	
	for _, s := range summaries {
		if s.RoomID == room.ID {
			return s, nil
		}
	}
	
	// If no message has been sent, GetRoomSummaries won't return it because of the HAVING clause, so construct it manually
	return &domain.RoomSummary{
		RoomID: room.ID,
		ParticipantID: receiverID,
	}, nil
}

func (u *communicationUsecase) GetRoomSummaries(ctx context.Context, tenantID, userID uuid.UUID) ([]*domain.RoomSummary, error) {
	return u.repo.GetRoomSummaries(ctx, tenantID, userID)
}

func (u *communicationUsecase) SaveMessage(ctx context.Context, roomID, senderID uuid.UUID, ciphertext string) (*domain.ChatMessage, error) {
	msg := &domain.ChatMessage{
		RoomID:     roomID,
		SenderID:   senderID,
		Ciphertext: ciphertext,
	}
	err := u.repo.SaveMessage(ctx, msg)
	return msg, err
}

func (u *communicationUsecase) GetMessagesByRoomID(ctx context.Context, roomID uuid.UUID) ([]*domain.ChatMessage, error) {
	return u.repo.GetMessagesByRoomID(ctx, roomID)
}

func (u *communicationUsecase) GetContacts(ctx context.Context, tenantID, userID uuid.UUID, role string) (*domain.ContactListResponse, error) {
	// For this app, role is always "parent"
	if role == "parent" {
		return u.repo.GetContactsForParent(ctx, tenantID, userID)
	}
	
	// Fallback empty response
	return &domain.ContactListResponse{
		Students: make([]*domain.ChatContact, 0),
		Parents:  make([]*domain.ChatContact, 0),
		Staff:    make([]*domain.ChatContact, 0),
	}, nil
}
