-- =============================================================================
-- Migration: Student Activity Features
-- Izin Siswa, Bimbingan Konseling (BK), Ekstrakulikuler
-- =============================================================================

-- ==========================================
-- STUDENT PERMITS (Izin Siswa)
-- ==========================================

CREATE TABLE IF NOT EXISTS student_permits (
    id              VARCHAR(36) PRIMARY KEY,
    tenant_id       VARCHAR(36) NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    student_id      VARCHAR(36) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type            VARCHAR(20) NOT NULL DEFAULT 'PERMISSION',
    reason          TEXT NOT NULL,
    start_date      DATE NOT NULL,
    end_date        DATE NOT NULL,
    status          VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    reviewed_by     VARCHAR(36) REFERENCES users(id),
    review_note     TEXT,
    attachment_url  TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_permits_tenant_student 
    ON student_permits(tenant_id, student_id);
CREATE INDEX IF NOT EXISTS idx_permits_status 
    ON student_permits(tenant_id, status);

-- ==========================================
-- COUNSELING SESSIONS (Bimbingan Konseling)
-- ==========================================

CREATE TABLE IF NOT EXISTS counseling_sessions (
    id              VARCHAR(36) PRIMARY KEY,
    tenant_id       VARCHAR(36) NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    student_id      VARCHAR(36) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    counselor_id    VARCHAR(36) REFERENCES users(id),
    topic           VARCHAR(255) NOT NULL,
    description     TEXT,
    preferred_date  DATE NOT NULL,
    scheduled_at    DATE,
    status          VARCHAR(20) NOT NULL DEFAULT 'REQUESTED',
    notes           TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_counseling_tenant_student 
    ON counseling_sessions(tenant_id, student_id);
CREATE INDEX IF NOT EXISTS idx_counseling_status 
    ON counseling_sessions(tenant_id, status);

-- ==========================================
-- EXTRACURRICULARS (Ekstrakulikuler)
-- ==========================================

CREATE TABLE IF NOT EXISTS extracurriculars (
    id              VARCHAR(36) PRIMARY KEY,
    tenant_id       VARCHAR(36) NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    name            VARCHAR(100) NOT NULL,
    description     TEXT,
    coach_name      VARCHAR(100),
    schedule        VARCHAR(200),
    max_members     INT NOT NULL DEFAULT 30,
    status          VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    image_url       TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_extracurriculars_tenant 
    ON extracurriculars(tenant_id, status);

-- ==========================================
-- EXTRACURRICULAR REGISTRATIONS
-- ==========================================

CREATE TABLE IF NOT EXISTS extracurricular_registrations (
    id                    VARCHAR(36) PRIMARY KEY,
    tenant_id             VARCHAR(36) NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    student_id            VARCHAR(36) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    extracurricular_id    VARCHAR(36) NOT NULL REFERENCES extracurriculars(id) ON DELETE CASCADE,
    status                VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    registered_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (student_id, extracurricular_id)
);

CREATE INDEX IF NOT EXISTS idx_extrareg_student 
    ON extracurricular_registrations(tenant_id, student_id);
CREATE INDEX IF NOT EXISTS idx_extrareg_extra 
    ON extracurricular_registrations(extracurricular_id, status);
