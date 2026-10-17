ALTER TABLE class_schedules
ADD COLUMN room VARCHAR(100),
ADD COLUMN activity_type ENUM('SUBJECT', 'CEREMONY', 'BREAK', 'EXTRACURRICULAR', 'EXAM', 'EVENT') DEFAULT 'SUBJECT',
ADD COLUMN activity_name VARCHAR(255),
ADD COLUMN description TEXT,
ADD COLUMN link VARCHAR(255);

CREATE TABLE schedule_changes (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(36) REFERENCES tenants(id),
    schedule_id VARCHAR(36) REFERENCES class_schedules(id),
    change_date DATE NOT NULL,
    new_staff_id VARCHAR(36) REFERENCES users(id),
    new_start_time TIME,
    new_end_time TIME,
    new_room VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(tenant_id, schedule_id, change_date)
);
