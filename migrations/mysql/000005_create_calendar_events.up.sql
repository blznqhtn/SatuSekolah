CREATE TABLE IF NOT EXISTS calendar_events (
    id CHAR(36) NOT NULL,
    tenant_id CHAR(36) NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    event_date DATE NOT NULL,
    start_time TIME NULL,
    end_time TIME NULL,
    location VARCHAR(255),
    category VARCHAR(50) NOT NULL, -- UJIAN, KEGIATAN, LIBUR, PEMBAYARAN, PENGUMUMAN, SPMB
    status VARCHAR(50) DEFAULT 'ACTIVE',
    attachment_url VARCHAR(255),
    created_by CHAR(36),
    target_user_id CHAR(36) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (target_user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_calendar_date (tenant_id, event_date),
    INDEX idx_calendar_user (target_user_id)
);
