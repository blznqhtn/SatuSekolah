CREATE TABLE teacher_evaluation_periods (
    id CHAR(36) PRIMARY KEY,
    tenant_id CHAR(36) NOT NULL,
    name VARCHAR(255) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
);

CREATE TABLE teacher_evaluation_categories (
    id CHAR(36) PRIMARY KEY,
    tenant_id CHAR(36) NOT NULL,
    name VARCHAR(255) NOT NULL,
    weight DECIMAL(5,2) DEFAULT 1.0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
);

-- Menggunakan skema yang memastikan anonimitas
-- Submission hanya mencatat partisipasi user untuk period_id dan teacher_id, mencegah duplikasi
CREATE TABLE teacher_evaluation_submissions (
    id CHAR(36) PRIMARY KEY,
    tenant_id CHAR(36) NOT NULL,
    period_id CHAR(36) NOT NULL,
    teacher_id CHAR(36) NOT NULL,
    evaluator_id CHAR(36) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    FOREIGN KEY (period_id) REFERENCES teacher_evaluation_periods(id) ON DELETE CASCADE,
    FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (evaluator_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_evaluation (period_id, teacher_id, evaluator_id)
);

-- Score berdiri sendiri, TIDAK TERIKAT pada evaluator_id maupun submission_id 
-- untuk menjamin 100% anonimitas secara fisik di database
CREATE TABLE teacher_evaluation_scores (
    id CHAR(36) PRIMARY KEY,
    tenant_id CHAR(36) NOT NULL,
    period_id CHAR(36) NOT NULL,
    teacher_id CHAR(36) NOT NULL,
    category_id CHAR(36) NOT NULL,
    score DECIMAL(5,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    FOREIGN KEY (period_id) REFERENCES teacher_evaluation_periods(id) ON DELETE CASCADE,
    FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES teacher_evaluation_categories(id) ON DELETE CASCADE
);

-- Komentar juga berdiri sendiri dan anonim
CREATE TABLE teacher_evaluation_comments (
    id CHAR(36) PRIMARY KEY,
    tenant_id CHAR(36) NOT NULL,
    period_id CHAR(36) NOT NULL,
    teacher_id CHAR(36) NOT NULL,
    advantages TEXT,
    disadvantages TEXT,
    suggestions TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    FOREIGN KEY (period_id) REFERENCES teacher_evaluation_periods(id) ON DELETE CASCADE,
    FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE CASCADE
);
