CREATE TABLE grade_components (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(36) REFERENCES tenants(id),
    course_id VARCHAR(36) REFERENCES courses(id),
    name VARCHAR(100) NOT NULL, -- "Tugas 1", "UTS", "UAS"
    weight DECIMAL(5,2) DEFAULT 1.0, -- Bobot komponen
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE student_grades (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(36) REFERENCES tenants(id),
    student_id VARCHAR(36) REFERENCES users(id),
    grade_component_id VARCHAR(36) REFERENCES grade_components(id),
    term_id VARCHAR(36) REFERENCES academic_terms(id),
    score DECIMAL(5,2) NOT NULL,
    teacher_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    updated_by VARCHAR(36) REFERENCES users(id)
);

CREATE TABLE report_card_notes (
    id VARCHAR(36) PRIMARY KEY,
    report_card_id VARCHAR(36) REFERENCES report_cards(id),
    category VARCHAR(50) NOT NULL, -- "ACADEMIC", "BEHAVIOR", "SUGGESTION", "EVALUATION"
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    updated_by VARCHAR(36) REFERENCES users(id)
);
