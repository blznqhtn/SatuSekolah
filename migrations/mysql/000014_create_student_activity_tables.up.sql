CREATE TABLE IF NOT EXISTS student_permits (
    id              CHAR(36) PRIMARY KEY,
    tenant_id       CHAR(36) NOT NULL,
    student_id      CHAR(36) NOT NULL,
    type            VARCHAR(20) NOT NULL DEFAULT 'PERMISSION',
    reason          TEXT NOT NULL,
    start_date      DATE NOT NULL,
    end_date        DATE NOT NULL,
    status          VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    reviewed_by     CHAR(36) NULL,
    review_note     TEXT NULL,
    attachment_url  TEXT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE SET NULL
);

CREATE INDEX idx_permits_tenant_student ON student_permits(tenant_id, student_id);
CREATE INDEX idx_permits_status ON student_permits(tenant_id, status);

CREATE TABLE IF NOT EXISTS counseling_sessions (
    id              CHAR(36) PRIMARY KEY,
    tenant_id       CHAR(36) NOT NULL,
    student_id      CHAR(36) NOT NULL,
    counselor_id    CHAR(36) NULL,
    topic           VARCHAR(255) NOT NULL,
    description     TEXT NULL,
    preferred_date  DATE NOT NULL,
    scheduled_at    DATE NULL,
    status          VARCHAR(20) NOT NULL DEFAULT 'REQUESTED',
    notes           TEXT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (counselor_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE INDEX idx_counseling_tenant_student ON counseling_sessions(tenant_id, student_id);
CREATE INDEX idx_counseling_status ON counseling_sessions(tenant_id, status);

CREATE TABLE IF NOT EXISTS extracurriculars (
    id              CHAR(36) PRIMARY KEY,
    tenant_id       CHAR(36) NOT NULL,
    name            VARCHAR(100) NOT NULL,
    description     TEXT NULL,
    coach_name      VARCHAR(100) NULL,
    schedule        VARCHAR(200) NULL,
    max_members     INT NOT NULL DEFAULT 30,
    status          VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    image_url       TEXT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
);

CREATE INDEX idx_extracurriculars_tenant ON extracurriculars(tenant_id, status);

CREATE TABLE IF NOT EXISTS extracurricular_registrations (
    id                    CHAR(36) PRIMARY KEY,
    tenant_id             CHAR(36) NOT NULL,
    student_id            CHAR(36) NOT NULL,
    extracurricular_id    CHAR(36) NOT NULL,
    status                VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    registered_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_student_extra (student_id, extracurricular_id),
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (extracurricular_id) REFERENCES extracurriculars(id) ON DELETE CASCADE
);

CREATE INDEX idx_extrareg_student ON extracurricular_registrations(tenant_id, student_id);
CREATE INDEX idx_extrareg_extra ON extracurricular_registrations(extracurricular_id, status);
