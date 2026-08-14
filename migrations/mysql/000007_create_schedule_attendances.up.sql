CREATE TABLE IF NOT EXISTS schedule_attendances (
    id CHAR(36) PRIMARY KEY,
    tenant_id CHAR(36) NOT NULL,
    schedule_id CHAR(36) NOT NULL,
    student_id CHAR(36) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'PRESENT', -- PRESENT, LATE, ABSENT, EXCUSED
    notes TEXT,
    recorded_by CHAR(36),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    FOREIGN KEY (schedule_id) REFERENCES class_schedules(id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (recorded_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_schedule_attendances_student (tenant_id, student_id, created_at)
);
