package repository

import (
	"context"
	"database/sql"

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
		INSERT INTO chat_rooms (id, tenant_id, type, participant_ids)
		VALUES (?, ?, ?, ?)
	`
	_, err := r.db.ExecContext(ctx, query, room.ID, room.TenantID, room.Type, room.ParticipantIDs)
	return err
}

func (r *communicationRepository) GetRoomByID(ctx context.Context, roomID uuid.UUID) (*domain.ChatRoom, error) {
	query := `
		SELECT id, tenant_id, type, participant_ids, created_at, updated_at
		FROM chat_rooms WHERE id = ?
	`
	var room domain.ChatRoom
	err := r.db.QueryRowContext(ctx, query, roomID).Scan(
		&room.ID, &room.TenantID, &room.Type, &room.ParticipantIDs, &room.CreatedAt, &room.UpdatedAt,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	return &room, nil
}

func (r *communicationRepository) GetRoomsByUserID(ctx context.Context, userID uuid.UUID) ([]*domain.ChatRoom, error) {
	// Simple JSON containment check for JSONB array. 
	// Assuming participant_ids is a JSON array of strings e.g., '["uuid1", "uuid2"]'
	// PostgreSQL: participant_ids @> '"uuid1"'
	// Since we support multiple databases, we'll just use a LIKE query as a fallback
	// For production with only Postgres, use: WHERE participant_ids @> '"$1"'
	
	// Given we are maintaining multi-DB compatibility (like in caching), 
	// a simple LIKE search works because UUIDs are unique and won't partially match.
	searchPattern := "%" + userID.String() + "%"
	query := `
		SELECT id, tenant_id, type, participant_ids, created_at, updated_at
		FROM chat_rooms WHERE participant_ids LIKE ?
		ORDER BY updated_at DESC
	`
	rows, err := r.db.QueryContext(ctx, query, searchPattern)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var rooms []*domain.ChatRoom
	for rows.Next() {
		var room domain.ChatRoom
		if err := rows.Scan(&room.ID, &room.TenantID, &room.Type, &room.ParticipantIDs, &room.CreatedAt, &room.UpdatedAt); err != nil {
			return nil, err
		}
		rooms = append(rooms, &room)
	}
	return rooms, nil
}

func (r *communicationRepository) SaveMessage(ctx context.Context, msg *domain.ChatMessage) error {
	msg.ID = uuid.New()
	query := `
		INSERT INTO chat_messages (id, room_id, sender_id, ciphertext)
		VALUES (?, ?, ?, ?)
	`
	_, err := r.db.ExecContext(ctx, query, msg.ID, msg.RoomID, msg.SenderID, msg.Ciphertext)
	if err != nil {
		return err
	}

	// Update room updated_at
	updateRoomQuery := `UPDATE chat_rooms SET updated_at = CURRENT_TIMESTAMP WHERE id = ?`
	_, _ = r.db.ExecContext(ctx, updateRoomQuery, msg.RoomID)

	return nil
}

func (r *communicationRepository) GetMessagesByRoomID(ctx context.Context, roomID uuid.UUID) ([]*domain.ChatMessage, error) {
	query := `
		SELECT id, room_id, sender_id, ciphertext, created_at
		FROM chat_messages WHERE room_id = ?
		ORDER BY created_at ASC
	`
	rows, err := r.db.QueryContext(ctx, query, roomID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var messages []*domain.ChatMessage
	for rows.Next() {
		var msg domain.ChatMessage
		if err := rows.Scan(&msg.ID, &msg.RoomID, &msg.SenderID, &msg.Ciphertext, &msg.CreatedAt); err != nil {
			return nil, err
		}
		messages = append(messages, &msg)
	}
	return messages, nil
}

func (r *communicationRepository) GetContacts(ctx context.Context, tenantID, userID uuid.UUID, category string) ([]*domain.ChatContact, error) {
	var contacts []*domain.ChatContact

	// Helper to run query
	runQuery := func(query string, args ...interface{}) error {
		rows, err := r.db.QueryContext(ctx, query, args...)
		if err != nil {
			return err
		}
		defer rows.Close()

		for rows.Next() {
			var c domain.ChatContact
			var className sql.NullString
			var publicKey sql.NullString
			if err := rows.Scan(&c.ID, &c.Name, &c.Category, &className, &publicKey); err != nil {
				return err
			}
			if className.Valid {
				c.ClassName = className.String
			}
			if publicKey.Valid {
				c.PublicKey = publicKey.String
			}
			// Don't add self to contacts
			if c.ID != userID {
				contacts = append(contacts, &c)
			}
		}
		return nil
	}

	switch category {
	case "student":
		// 1. Get Classmates
		qClassmates := `
			SELECT u.id, u.name, u.category, c.name, u.public_key 
			FROM users u 
			LEFT JOIN classes c ON u.class_id = c.id 
			WHERE u.tenant_id = ? AND u.class_id = (SELECT class_id FROM users WHERE id = ?)
		`
		if err := runQuery(qClassmates, tenantID, userID); err != nil {
			return nil, err
		}

		// 2. Get Staff & Admin
		qStaff := `
			SELECT u.id, u.name, u.category, NULL, u.public_key 
			FROM users u 
			WHERE u.tenant_id = ? AND u.category IN ('staff', 'admin')
		`
		if err := runQuery(qStaff, tenantID); err != nil {
			return nil, err
		}

	case "parent":
		// 1. Get Children
		qChildren := `
			SELECT u.id, u.name, u.category, c.name, u.public_key 
			FROM users u 
			LEFT JOIN classes c ON u.class_id = c.id 
			WHERE u.tenant_id = ? AND u.parent_id = ?
		`
		if err := runQuery(qChildren, tenantID, userID); err != nil {
			return nil, err
		}

		// 2. Get Children's Classmates
		qClassmates := `
			SELECT u.id, u.name, u.category, c.name, u.public_key 
			FROM users u 
			LEFT JOIN classes c ON u.class_id = c.id 
			WHERE u.tenant_id = ? AND u.class_id IN (SELECT class_id FROM users WHERE parent_id = ?)
		`
		if err := runQuery(qClassmates, tenantID, userID); err != nil {
			return nil, err
		}

		// 3. Get Parents of Children's Classmates
		qOtherParents := `
			SELECT p.id, p.name, p.category, NULL, p.public_key
			FROM users p
			WHERE p.tenant_id = ? AND p.id IN (
				SELECT parent_id FROM users 
				WHERE class_id IN (SELECT class_id FROM users WHERE parent_id = ?) 
				AND parent_id IS NOT NULL
			)
		`
		if err := runQuery(qOtherParents, tenantID, userID); err != nil {
			return nil, err
		}

		// 4. Get Staff & Admin
		qStaff := `
			SELECT u.id, u.name, u.category, NULL, u.public_key 
			FROM users u 
			WHERE u.tenant_id = ? AND u.category IN ('staff', 'admin')
		`
		if err := runQuery(qStaff, tenantID); err != nil {
			return nil, err
		}

	case "staff", "admin":
		// Can see everyone in the tenant
		qAll := `
			SELECT u.id, u.name, u.category, c.name, u.public_key 
			FROM users u 
			LEFT JOIN classes c ON u.class_id = c.id 
			WHERE u.tenant_id = ?
		`
		if err := runQuery(qAll, tenantID); err != nil {
			return nil, err
		}
	}

	// Remove duplicates since some queries might overlap (e.g. a child is also a classmate)
	uniqueMap := make(map[uuid.UUID]*domain.ChatContact)
	for _, c := range contacts {
		uniqueMap[c.ID] = c
	}

	var result []*domain.ChatContact
	for _, c := range uniqueMap {
		result = append(result, c)
	}

	return result, nil
}
