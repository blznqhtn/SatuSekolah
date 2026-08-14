CREATE TABLE chat_rooms (
    id CHAR(36) PRIMARY KEY,
    tenant_id CHAR(36) NOT NULL,
    type VARCHAR(20) NOT NULL DEFAULT 'DIRECT', -- DIRECT, GROUP
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
);

CREATE TABLE chat_room_participants (
    room_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    last_read_at TIMESTAMP NULL,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (room_id, user_id),
    FOREIGN KEY (room_id) REFERENCES chat_rooms(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE chat_messages (
    id CHAR(36) PRIMARY KEY,
    room_id CHAR(36) NOT NULL,
    sender_id CHAR(36) NOT NULL,
    ciphertext TEXT NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (room_id) REFERENCES chat_rooms(id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE user_presence (
    user_id CHAR(36) PRIMARY KEY,
    is_online BOOLEAN DEFAULT FALSE,
    last_seen_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
