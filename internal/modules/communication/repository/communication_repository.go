package repository

import (
	"context"
	"database/sql"
	"time"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/communication/domain"
)

type communicationRepository struct {
	db *sql.DB
}

func NewCommunicationRepository(db *sql.DB) domain.CommunicationRepository {
	return &communicationRepository{db: db}
}

func (r *communicationRepository) CreateRoom(ctx context.Context, room *domain.ChatRoom) error {
	room.ID = uuid.New()
	query := `
		INSERT INTO chat_rooms (id, tenant_id, type)
		VALUES (?, ?, ?)
	`
	_, err := r.db.ExecContext(ctx, query, room.ID, room.TenantID, room.Type)
	return err
}

func (r *communicationRepository) AddParticipant(ctx context.Context, roomID, userID uuid.UUID) error {
	query := `
		INSERT INTO chat_room_participants (room_id, user_id)
		VALUES (?, ?)
		ON DUPLICATE KEY UPDATE joined_at=joined_at
	`
	_, err := r.db.ExecContext(ctx, query, roomID, userID)
	return err
}

func (r *communicationRepository) GetDirectRoom(ctx context.Context, user1, user2 uuid.UUID) (*domain.ChatRoom, error) {
	query := `
		SELECT cr.id, cr.tenant_id, cr.type, cr.created_at
		FROM chat_rooms cr
		JOIN chat_room_participants p1 ON p1.room_id = cr.id AND p1.user_id = ?
		JOIN chat_room_participants p2 ON p2.room_id = cr.id AND p2.user_id = ?
		WHERE cr.type = 'DIRECT'
		LIMIT 1
	`
	var room domain.ChatRoom
	err := r.db.QueryRowContext(ctx, query, user1, user2).Scan(
		&room.ID, &room.TenantID, &room.Type, &room.CreatedAt,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	return &room, nil
}

func (r *communicationRepository) GetRoomSummaries(ctx context.Context, tenantID, userID uuid.UUID) ([]*domain.RoomSummary, error) {
	// Fetch room list for a user, including the other participant (for DIRECT chats), latest message, unread count, and online status.
	query := `
		SELECT 
			cr.id,
			u.name AS participant_name,
			u.id AS participant_id,
			u.category AS role,
			IFNULL(up.is_online, FALSE) AS is_online,
			IFNULL(u.public_key, '') AS public_key,
			(SELECT ciphertext FROM chat_messages WHERE room_id = cr.id ORDER BY sent_at DESC LIMIT 1) AS last_message,
			(SELECT sent_at FROM chat_messages WHERE room_id = cr.id ORDER BY sent_at DESC LIMIT 1) AS last_message_at,
			(SELECT COUNT(*) FROM chat_messages cm WHERE cm.room_id = cr.id AND cm.sender_id != ? AND (cm.sent_at > my_p.last_read_at OR my_p.last_read_at IS NULL)) AS unread_count
		FROM chat_rooms cr
		JOIN chat_room_participants my_p ON my_p.room_id = cr.id AND my_p.user_id = ?
		JOIN chat_room_participants other_p ON other_p.room_id = cr.id AND other_p.user_id != ?
		JOIN users u ON u.id = other_p.user_id
		LEFT JOIN user_presence up ON up.user_id = u.id
		WHERE cr.tenant_id = ? AND cr.type = 'DIRECT'
		HAVING last_message_at IS NOT NULL
		ORDER BY last_message_at DESC
	`
	rows, err := r.db.QueryContext(ctx, query, userID, userID, userID, tenantID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var summaries []*domain.RoomSummary
	for rows.Next() {
		var s domain.RoomSummary
		var lastMsg, pubKey sql.NullString
		var lastMsgAt sql.NullTime
		if err := rows.Scan(&s.RoomID, &s.ParticipantName, &s.ParticipantID, &s.Role, &s.IsOnline, &pubKey, &lastMsg, &lastMsgAt, &s.UnreadCount); err != nil {
			return nil, err
		}
		if lastMsg.Valid {
			s.LastMessage = lastMsg.String
		}
		if lastMsgAt.Valid {
			s.LastMessageAt = lastMsgAt.Time
		}
		if pubKey.Valid {
			s.PublicKey = pubKey.String
		}
		summaries = append(summaries, &s)
	}
	return summaries, nil
}

func (r *communicationRepository) SaveMessage(ctx context.Context, msg *domain.ChatMessage) error {
	msg.ID = uuid.New()
	msg.SentAt = time.Now()
	query := `
		INSERT INTO chat_messages (id, room_id, sender_id, ciphertext, sent_at)
		VALUES (?, ?, ?, ?, ?)
	`
	_, err := r.db.ExecContext(ctx, query, msg.ID, msg.RoomID, msg.SenderID, msg.Ciphertext, msg.SentAt)
	return err
}

func (r *communicationRepository) GetMessagesByRoomID(ctx context.Context, roomID uuid.UUID) ([]*domain.ChatMessage, error) {
	query := `
		SELECT id, room_id, sender_id, ciphertext, sent_at
		FROM chat_messages WHERE room_id = ?
		ORDER BY sent_at ASC
	`
	rows, err := r.db.QueryContext(ctx, query, roomID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var messages []*domain.ChatMessage
	for rows.Next() {
		var msg domain.ChatMessage
		if err := rows.Scan(&msg.ID, &msg.RoomID, &msg.SenderID, &msg.Ciphertext, &msg.SentAt); err != nil {
			return nil, err
		}
		messages = append(messages, &msg)
	}
	return messages, nil
}

func (r *communicationRepository) GetContactsForParent(ctx context.Context, tenantID, parentID uuid.UUID) (*domain.ContactListResponse, error) {
	var contacts domain.ContactListResponse
	
	// Helper to run query and return contacts
	runQuery := func(query string, args ...interface{}) ([]*domain.ChatContact, error) {
		rows, err := r.db.QueryContext(ctx, query, args...)
		if err != nil {
			return nil, err
		}
		defer rows.Close()

		var res []*domain.ChatContact
		for rows.Next() {
			var c domain.ChatContact
			var className sql.NullString
			var publicKey sql.NullString
			if err := rows.Scan(&c.ID, &c.Name, &c.Category, &className, &publicKey); err != nil {
				return nil, err
			}
			if className.Valid {
				c.ClassName = className.String
			}
			if publicKey.Valid {
				c.PublicKey = publicKey.String
			}
			res = append(res, &c)
		}
		return res, nil
	}

	// 1. Children (Anaknya sendiri)
	children, err := runQuery(`
		SELECT u.id, u.name, u.category, c.name, u.public_key 
		FROM users u 
		LEFT JOIN classes c ON u.class_id = c.id 
		WHERE u.tenant_id = ? AND u.parent_id = ?`, tenantID, parentID)
	if err == nil {
		contacts.Students = append(contacts.Students, children...)
	}

	// 2. Parents of Classmates (Wali murid yang sekelas dengan anaknya)
	otherParents, err := runQuery(`
		SELECT DISTINCT p.id, p.name, p.category, NULL, p.public_key
		FROM users p
		JOIN users child ON child.parent_id = p.id
		WHERE p.tenant_id = ? AND p.id != ? AND child.class_id IN (
			SELECT class_id FROM users WHERE parent_id = ?
		)
	`, tenantID, parentID, parentID)
	if err == nil {
		contacts.Parents = append(contacts.Parents, otherParents...)
	}

	// 3. Staff & Admin & Teachers
	// For teachers, specifically those teaching the child or homeroom teachers
	staff, err := runQuery(`
		SELECT DISTINCT u.id, u.name, u.category, NULL, u.public_key 
		FROM users u 
		LEFT JOIN class_schedules cs ON cs.staff_id = u.id
		LEFT JOIN classes c ON c.homeroom_teacher_id = u.id
		WHERE u.tenant_id = ? AND u.category IN ('staff', 'admin')
		AND (
			u.category = 'admin' OR 
			cs.class_id IN (SELECT class_id FROM users WHERE parent_id = ?) OR
			c.id IN (SELECT class_id FROM users WHERE parent_id = ?)
		)
	`, tenantID, parentID, parentID)
	if err == nil {
		contacts.Staff = append(contacts.Staff, staff...)
	}

	return &contacts, nil
}

func (r *communicationRepository) UpdatePresence(ctx context.Context, userID uuid.UUID, isOnline bool) error {
	query := `
		INSERT INTO user_presence (user_id, is_online, last_seen_at) 
		VALUES (?, ?, NOW())
		ON DUPLICATE KEY UPDATE is_online = VALUES(is_online), last_seen_at = NOW()
	`
	_, err := r.db.ExecContext(ctx, query, userID, isOnline)
	return err
}
