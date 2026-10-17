CREATE TABLE health_checkups (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(36) REFERENCES tenants(id),
    student_id VARCHAR(36) REFERENCES users(id),
    examiner_id VARCHAR(36) REFERENCES users(id),
    date DATETIME,
    temperature DECIMAL(4,1),
    blood_pressure VARCHAR(20),
    weight DECIMAL(5,2),
    height DECIMAL(5,2),
    complaint TEXT,
    diagnosis TEXT,
    treatment TEXT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE health_medical_history (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(36) REFERENCES tenants(id),
    student_id VARCHAR(36) REFERENCES users(id),
    blood_type VARCHAR(5),
    allergies TEXT,
    chronic_diseases TEXT,
    special_conditions TEXT,
    updated_at TIMESTAMP,
    UNIQUE(tenant_id, student_id)
);
