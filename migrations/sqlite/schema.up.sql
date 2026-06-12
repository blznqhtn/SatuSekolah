-- ==========================================
-- 1. CORE & MULTI-TENANT
-- ==========================================
CREATE TABLE tenants (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    bank_code VARCHAR(3) UNIQUE NOT NULL,
    npsn VARCHAR(50) UNIQUE,
    domain VARCHAR(255) UNIQUE,
    address TEXT,
    phone VARCHAR(50),
    email VARCHAR(255),
    logo_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP
);

-- ==========================================
-- 2. RBAC (GRANULAR ROLES & PERMISSIONS)
-- ==========================================
CREATE TABLE roles (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(36) REFERENCES tenants(id),
    name VARCHAR(100) NOT NULL,
    is_custom BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE permissions (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE role_permissions (
    role_id VARCHAR(36) REFERENCES roles(id),
    permission_id VARCHAR(36) REFERENCES permissions(id),
    PRIMARY KEY (role_id, permission_id)
);

-- Seed System Permissions
INSERT INTO permissions (id, name) VALUES 
('p-001', 'MANAGE_ATTENDANCE'),
('p-002', 'MANAGE_LMS'),
('p-003', 'MANAGE_FINANCE'),
('p-004', 'MANAGE_LIBRARY'),
('p-005', 'MANAGE_CBA'),
('p-006', 'MANAGE_HEALTH'),
('p-007', 'MANAGE_INVENTORY'),
('p-008', 'MANAGE_SPMB'),
('p-009', 'MANAGE_ROLES_PERMISSIONS'),
('p-010', 'MANAGE_USERS'),
('p-011', 'MANAGE_VIOLATIONS');

-- ==========================================
-- 3. MAJORS & CLASSES (referenced early by users)
-- ==========================================
CREATE TABLE majors (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(36) REFERENCES tenants(id),
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE TABLE classes (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(36) REFERENCES tenants(id),
    major_id VARCHAR(36) REFERENCES majors(id),
    grade_level INT,
    name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

-- ==========================================
-- 4. CENTRALIZED USERS
-- ==========================================
CREATE TABLE users (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(36) REFERENCES tenants(id),
    class_id VARCHAR(36) REFERENCES classes(id),
    account_number VARCHAR(12) UNIQUE NOT NULL,
    category ENUM('admin', 'staff', 'student', 'parent') NOT NULL,
    status ENUM('CANDIDATE', 'ACTIVE', 'ALUMNI', 'SUSPENDED') DEFAULT 'ACTIVE',
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(50),
    password_hash VARCHAR(255),
    pin_hash VARCHAR(255),
    identifier VARCHAR(100),
    rfid_tag VARCHAR(100) UNIQUE,
    face_encoding TEXT,
    wallet_balance DECIMAL(15,2) DEFAULT 0,
    public_key TEXT,
    parent_id VARCHAR(36) REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP,
    UNIQUE (tenant_id, email)
);

CREATE INDEX idx_users_tenant_identifier ON users(tenant_id, identifier);
CREATE INDEX idx_users_tenant_class ON users(tenant_id, class_id);

CREATE TABLE user_roles (
    user_id VARCHAR(36) REFERENCES users(id),
    role_id VARCHAR(36) REFERENCES roles(id),
    PRIMARY KEY (user_id, role_id)
);

-- ==========================================
-- 5. PAYOUT SETTINGS & WALLET LEDGER (WEB3)
-- ==========================================
CREATE TABLE payout_methods (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) REFERENCES users(id),
    provider_name VARCHAR(100),
    account_number VARCHAR(100),
    account_name VARCHAR(255),
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE wallet_ledgers (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(36) REFERENCES tenants(id),
    user_id VARCHAR(36) REFERENCES users(id),
    transaction_type ENUM('CREDIT', 'DEBIT') NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    fee DECIMAL(10,2) DEFAULT 0,
    reference_type VARCHAR(100),
    reference_id VARCHAR(36),
    previous_hash VARCHAR(64) NOT NULL,
    current_hash VARCHAR(64) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_wallet_ledgers_user_date ON wallet_ledgers(tenant_id, user_id, created_at);

-- ==========================================
-- 6. ATTENDANCE, HOLIDAYS & ACTIVITIES
-- ==========================================
CREATE TABLE attendance_settings (
    tenant_id VARCHAR(36) PRIMARY KEY REFERENCES tenants(id),
    attendance_admin_staff_id VARCHAR(36) REFERENCES users(id),
    holiday_manager_role_id VARCHAR(36) REFERENCES roles(id),
    -- Student Schedule
    student_check_in_time TIME DEFAULT '07:00:00',
    student_check_out_time TIME DEFAULT '15:00:00',
    student_tolerance_minutes INT DEFAULT 15,
    -- Staff / Teacher Schedule (typically different from students)
    staff_check_in_time TIME DEFAULT '07:30:00',
    staff_check_out_time TIME DEFAULT '16:00:00',
    staff_tolerance_minutes INT DEFAULT 10,
    allow_rfid BOOLEAN DEFAULT TRUE,
    allow_fingerprint BOOLEAN DEFAULT TRUE,
    allow_face BOOLEAN DEFAULT TRUE,
    face_match_threshold DECIMAL(5,2) DEFAULT 80.00,
    updated_at TIMESTAMP,
    updated_by VARCHAR(36) REFERENCES users(id)
);

CREATE TABLE holidays (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(36) REFERENCES tenants(id),
    name VARCHAR(255) NOT NULL,
    date DATE NOT NULL,
    applies_to ENUM('STUDENT', 'STAFF', 'ALL') DEFAULT 'ALL',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(36) REFERENCES users(id)
);

CREATE TABLE activities (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(36) REFERENCES tenants(id),
    name VARCHAR(255) NOT NULL,
    is_mandatory BOOLEAN DEFAULT FALSE,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    requires_checkout BOOLEAN DEFAULT FALSE,
    replaces_daily_attendance BOOLEAN DEFAULT FALSE,
    created_by VARCHAR(36) REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE activity_targets (
    id VARCHAR(36) PRIMARY KEY,
    activity_id VARCHAR(36) REFERENCES activities(id),
    target_type ENUM('USER', 'CLASS', 'MAJOR') NOT NULL,
    target_id VARCHAR(36) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE activity_attendances (
    id VARCHAR(36) PRIMARY KEY,
    activity_id VARCHAR(36) REFERENCES activities(id),
    user_id VARCHAR(36) REFERENCES users(id),
    check_in_at TIMESTAMP,
    check_out_at TIMESTAMP,
    status ENUM('PRESENT', 'LATE', 'ABSENT', 'EXCUSED') DEFAULT 'PRESENT',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(activity_id, user_id)
);

CREATE TABLE attendances (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(36) REFERENCES tenants(id),
    user_id VARCHAR(36) REFERENCES users(id),
    type VARCHAR(100), -- 'DAILY' or 'ACTIVITY_REPLACEMENT'
    method VARCHAR(50), -- 'RFID', 'FACE', 'FINGERPRINT', 'SYSTEM'
    check_in_at TIMESTAMP,
    check_out_at TIMESTAMP,
    status ENUM('PRESENT', 'LATE', 'ABSENT', 'EXCUSED'),
    notes TEXT
);

CREATE INDEX idx_attendances_user_date ON attendances(tenant_id, user_id, check_in_at);

CREATE TABLE attendance_lates (
    id VARCHAR(36) PRIMARY KEY,
    attendance_id VARCHAR(36) REFERENCES attendances(id),
    reason TEXT,
    submitted_at TIMESTAMP,
    is_excused BOOLEAN DEFAULT FALSE,
    reviewed_by VARCHAR(36) REFERENCES users(id)
);

-- ==========================================
-- 7. VIOLATION POINTS SYSTEM
-- ==========================================
CREATE TABLE violation_types (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(36) REFERENCES tenants(id),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    points INT DEFAULT 0,
    -- applies_to: who this violation category applies to
    applies_to ENUM('STUDENT', 'STAFF', 'ALL') DEFAULT 'ALL',
    -- is_active: admin/student affairs can disable a type without deleting it
    is_active BOOLEAN DEFAULT TRUE,
    -- is_system_default: true = cannot be deleted (e.g., LATE_ATTENDANCE)
    is_system_default BOOLEAN DEFAULT FALSE,
    created_by VARCHAR(36) REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Seed default system violation types (poin default 0, bisa diubah per tenant)
INSERT INTO violation_types (id, name, description, points, applies_to, is_system_default)
VALUES
('vt-001', 'LATE_ATTENDANCE_STUDENT', 'Terlambat masuk sekolah (siswa)', 0, 'STUDENT', TRUE),
('vt-002', 'LATE_ATTENDANCE_STAFF', 'Terlambat masuk kerja (staf/guru)', 0, 'STAFF', TRUE);

CREATE TABLE user_violations (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(36) REFERENCES tenants(id),
    user_id VARCHAR(36) REFERENCES users(id),
    violation_type_id VARCHAR(36) REFERENCES violation_types(id),
    -- points_applied: actual points at time of recording (violation type points can change later)
    points_applied INT NOT NULL,
    evidence_url VARCHAR(255),
    notes TEXT,
    -- recorded_by: the staff member who recorded the violation (NULL if triggered by system)
    recorded_by VARCHAR(36) REFERENCES users(id),
    -- parent_notified: whether the parent was sent a push notification
    parent_notified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE leave_requests (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(36) REFERENCES tenants(id),
    user_id VARCHAR(36) REFERENCES users(id),
    reason TEXT,
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    status ENUM('PENDING', 'APPROVED', 'REJECTED') DEFAULT 'PENDING',
    current_tier INT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE leave_approvals (
    id VARCHAR(36) PRIMARY KEY,
    leave_request_id VARCHAR(36) REFERENCES leave_requests(id),
    approver_role_id VARCHAR(36) REFERENCES roles(id),
    tier_level INT,
    status ENUM('PENDING', 'APPROVED', 'REJECTED') DEFAULT 'PENDING',
    approved_by VARCHAR(36) REFERENCES users(id),
    approved_at TIMESTAMP
);

-- ==========================================
-- 7. AI QUOTAS & MODULE SETTINGS
-- ==========================================
CREATE TABLE ai_tenant_quotas (
    tenant_id VARCHAR(36) PRIMARY KEY REFERENCES tenants(id),
    total_input_tokens BIGINT DEFAULT 1000000,
    input_tokens_used BIGINT DEFAULT 0,
    total_output_tokens BIGINT DEFAULT 1000000,
    output_tokens_used BIGINT DEFAULT 0,
    updated_at TIMESTAMP
);

CREATE TABLE ai_module_settings (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(36) REFERENCES tenants(id),
    module_name VARCHAR(50) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    updated_at TIMESTAMP,
    UNIQUE(tenant_id, module_name)
);

-- ==========================================
-- 8. HEALTH RECORDS (UKS)
-- ==========================================
CREATE TABLE health_records (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(36) REFERENCES tenants(id),
    user_id VARCHAR(36) REFERENCES users(id),
    record_type VARCHAR(100),
    date DATE,
    height DECIMAL(5,2),
    weight DECIMAL(5,2),
    hearing VARCHAR(100),
    vision VARCHAR(100),
    dental VARCHAR(100),
    hemoglobin DECIMAL(5,2),
    notes TEXT,
    ai_recommendation TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    updated_by VARCHAR(36) REFERENCES users(id)
);

CREATE TABLE health_settings (
    tenant_id CHAR(36) PRIMARY KEY,
    health_admin_user_id CHAR(36) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    FOREIGN KEY (health_admin_user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE menstrual_cycles (
    id CHAR(36) PRIMARY KEY,
    tenant_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    symptoms TEXT,
    ai_advice TEXT,
    status ENUM('ONGOING', 'COMPLETED', 'BLOCKED_OVERDUE') DEFAULT 'ONGOING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE ribbon_borrowings (
    id CHAR(36) PRIMARY KEY,
    tenant_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    cycle_id CHAR(36) NOT NULL,
    borrowed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expected_return_at TIMESTAMP NOT NULL,
    returned_at TIMESTAMP,
    status ENUM('BORROWED', 'RETURNED', 'OVERDUE') DEFAULT 'BORROWED',
    sanction_notes TEXT,
    handled_by CHAR(36),
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (cycle_id) REFERENCES menstrual_cycles(id) ON DELETE CASCADE,
    FOREIGN KEY (handled_by) REFERENCES users(id) ON DELETE SET NULL
);

-- ==========================================
-- 9. REIMBURSEMENT
-- ==========================================
CREATE TABLE reimbursements (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(36) REFERENCES tenants(id),
    user_id VARCHAR(36) REFERENCES users(id),
    amount DECIMAL(15,2),
    description TEXT,
    receipt_file_url VARCHAR(255),
    status ENUM('PENDING', 'APPROVED', 'REJECTED') DEFAULT 'PENDING',
    approved_by VARCHAR(36) REFERENCES users(id),
    approved_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- ==========================================
-- 10. PENILAIAN KINERJA GURU / STAFF (PKG)
-- ==========================================
CREATE TABLE pkg_periods (
    id CHAR(36) PRIMARY KEY,
    tenant_id CHAR(36) NOT NULL,
    name VARCHAR(255) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
);

CREATE TABLE pkg_indicators (
    id CHAR(36) PRIMARY KEY,
    tenant_id CHAR(36) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    weight DECIMAL(5,2) DEFAULT 1.0,
    is_applicable_to_all BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
);

CREATE TABLE pkg_submissions (
    id CHAR(36) PRIMARY KEY,
    period_id CHAR(36) NOT NULL,
    indicator_id CHAR(36) NOT NULL,
    staff_id CHAR(36) NOT NULL,
    document_url VARCHAR(255) NOT NULL,
    description TEXT,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (period_id) REFERENCES pkg_periods(id) ON DELETE CASCADE,
    FOREIGN KEY (indicator_id) REFERENCES pkg_indicators(id) ON DELETE CASCADE,
    FOREIGN KEY (staff_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE pkg_evaluations (
    id CHAR(36) PRIMARY KEY,
    submission_id CHAR(36) NOT NULL,
    evaluator_id CHAR(36) NOT NULL,
    score DECIMAL(5,2) NOT NULL,
    comments TEXT,
    evaluated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (submission_id) REFERENCES pkg_submissions(id) ON DELETE CASCADE,
    FOREIGN KEY (evaluator_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ==========================================
-- 11. DYNAMIC FORMS
-- ==========================================
CREATE TABLE dynamic_forms (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(36) REFERENCES tenants(id),
    title VARCHAR(255),
    description TEXT,
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    target_audience VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_by VARCHAR(36) REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE TABLE form_questions (
    id VARCHAR(36) PRIMARY KEY,
    form_id VARCHAR(36) REFERENCES dynamic_forms(id),
    question_type VARCHAR(50),
    question_text TEXT,
    is_required BOOLEAN DEFAULT TRUE,
    order_index INT,
    metadata JSON
);

CREATE TABLE form_responses (
    id VARCHAR(36) PRIMARY KEY,
    form_id VARCHAR(36) REFERENCES dynamic_forms(id),
    responder_id VARCHAR(36) REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE form_answers (
    id VARCHAR(36) PRIMARY KEY,
    response_id VARCHAR(36) REFERENCES form_responses(id),
    question_id VARCHAR(36) REFERENCES form_questions(id),
    answer_text TEXT
);

-- ==========================================
-- 12. AKADEMIK (TAHUN AJARAN, KURSUS, LMS)
-- ==========================================
CREATE TABLE academic_years (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(36) REFERENCES tenants(id),
    name VARCHAR(100),
    start_date DATE,
    end_date DATE,
    is_active BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE courses (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(36) REFERENCES tenants(id),
    name VARCHAR(255),
    staff_id VARCHAR(36) REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE TABLE modules (
    id VARCHAR(36) PRIMARY KEY,
    course_id VARCHAR(36) REFERENCES courses(id),
    title VARCHAR(255),
    content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE TABLE quizzes (
    id VARCHAR(36) PRIMARY KEY,
    module_id VARCHAR(36) REFERENCES modules(id),
    title VARCHAR(255),
    deleted_at TIMESTAMP
);

CREATE TABLE questions (
    id VARCHAR(36) PRIMARY KEY,
    quiz_id VARCHAR(36) REFERENCES quizzes(id),
    type VARCHAR(50),
    -- e.g. 'MULTIPLE_CHOICE', 'MULTIPLE_SELECT', 'ESSAY', 'MATCHING'
    question_text TEXT,
    media_url VARCHAR(255),
    media_type ENUM('IMAGE', 'AUDIO', 'VIDEO', 'DOCUMENT', 'NONE') DEFAULT 'NONE',
    ai_reference_answer TEXT,
    deleted_at TIMESTAMP
);

CREATE TABLE question_options (
    id CHAR(36) PRIMARY KEY,
    question_id CHAR(36) NOT NULL,
    option_text TEXT,
    media_url VARCHAR(255),
    media_type ENUM('IMAGE', 'AUDIO', 'VIDEO', 'DOCUMENT', 'NONE') DEFAULT 'NONE',
    is_correct BOOLEAN DEFAULT FALSE,
    match_left TEXT,
    match_right TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE
);

CREATE TABLE student_answers (
    id VARCHAR(36) PRIMARY KEY,
    question_id VARCHAR(36) REFERENCES questions(id),
    student_id VARCHAR(36) REFERENCES users(id),
    answer_text TEXT,
    is_correct BOOLEAN,
    ai_score DECIMAL(5,2),
    ai_feedback TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE assignment_targets (
    id CHAR(36) PRIMARY KEY,
    source_type ENUM('COURSE', 'QUIZ') NOT NULL,
    source_id CHAR(36) NOT NULL,
    target_type ENUM('CLASS', 'MAJOR', 'ROLE', 'USER') NOT NULL,
    target_id CHAR(36) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================
-- 13. JADWAL PELAJARAN
-- ==========================================
CREATE TABLE class_schedules (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(36) REFERENCES tenants(id),
    class_id VARCHAR(36) REFERENCES classes(id),
    course_id VARCHAR(36) REFERENCES courses(id),
    staff_id VARCHAR(36) REFERENCES users(id),
    day_of_week INT,
    start_time TIME,
    end_time TIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- ==========================================
-- 14. MANAJEMEN TARIF & TAGIHAN (INVOICING)
-- ==========================================
CREATE TABLE fee_types (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(36) REFERENCES tenants(id),
    name VARCHAR(100),
    billing_cycle VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE TABLE fees (
    id VARCHAR(36) PRIMARY KEY,
    fee_type_id VARCHAR(36) REFERENCES fee_types(id),
    major_id VARCHAR(36) REFERENCES majors(id),
    grade_level INT,
    amount DECIMAL(15,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP,
    updated_by VARCHAR(36) REFERENCES users(id)
);

CREATE TABLE student_invoices (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(36) REFERENCES tenants(id),
    student_id VARCHAR(36) REFERENCES users(id),
    fee_id VARCHAR(36) REFERENCES fees(id),
    invoice_name VARCHAR(255),
    total_amount DECIMAL(15,2),
    paid_amount DECIMAL(15,2) DEFAULT 0,
    status ENUM('PENDING', 'PARTIAL', 'PAID') DEFAULT 'PENDING',
    due_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP,
    updated_by VARCHAR(36) REFERENCES users(id)
);

CREATE INDEX idx_student_invoices_status ON student_invoices(tenant_id, student_id, status);

CREATE TABLE invoice_payments (
    id VARCHAR(36) PRIMARY KEY,
    invoice_id VARCHAR(36) REFERENCES student_invoices(id),
    wallet_ledger_id VARCHAR(36) REFERENCES wallet_ledgers(id),
    paid_amount DECIMAL(15,2),
    paid_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================
-- 15. RAPOR DIGITAL
-- ==========================================
CREATE TABLE academic_terms (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(36) REFERENCES tenants(id),
    academic_year_id VARCHAR(36) REFERENCES academic_years(id),
    name VARCHAR(100),
    is_active BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE report_cards (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(36) REFERENCES tenants(id),
    term_id VARCHAR(36) REFERENCES academic_terms(id),
    student_id VARCHAR(36) REFERENCES users(id),
    class_rank INT,
    homeroom_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    updated_by VARCHAR(36) REFERENCES users(id)
);

CREATE TABLE report_card_grades (
    id VARCHAR(36) PRIMARY KEY,
    report_card_id VARCHAR(36) REFERENCES report_cards(id),
    course_id VARCHAR(36) REFERENCES courses(id),
    score INT,
    predicate VARCHAR(5),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- ==========================================
-- 16. POIN PELANGGARAN
-- ==========================================
CREATE TABLE violation_types (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(36) REFERENCES tenants(id),
    name VARCHAR(255),
    point_weight INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE TABLE student_violations (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(36) REFERENCES tenants(id),
    student_id VARCHAR(36) REFERENCES users(id),
    violation_type_id VARCHAR(36) REFERENCES violation_types(id),
    reported_by VARCHAR(36) REFERENCES users(id),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP
);

-- ==========================================
-- 17. DIGITAL CANTEEN
-- ==========================================
CREATE TABLE canteen_shops (
    id CHAR(36) PRIMARY KEY,
    tenant_id CHAR(36),
    owner_id CHAR(36),
    name VARCHAR(255) NOT NULL,
    static_qr_code VARCHAR(255) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id),
    FOREIGN KEY (owner_id) REFERENCES users(id)
);

CREATE TABLE canteen_items (
    id CHAR(36) PRIMARY KEY,
    shop_id CHAR(36),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(15,2) NOT NULL,
    stock INT DEFAULT 0,
    image_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    FOREIGN KEY (shop_id) REFERENCES canteen_shops(id)
);

CREATE TABLE canteen_carts (
    id CHAR(36) PRIMARY KEY,
    user_id CHAR(36),
    item_id CHAR(36),
    quantity INT NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (item_id) REFERENCES canteen_items(id)
);

CREATE TABLE canteen_orders (
    id CHAR(36) PRIMARY KEY,
    shop_id CHAR(36),
    buyer_id CHAR(36),
    wallet_ledger_id CHAR(36),
    total_amount DECIMAL(15,2) NOT NULL,
    delivery_fee DECIMAL(15,2) DEFAULT 0,
    is_preorder BOOLEAN DEFAULT FALSE,
    preorder_time TIME,
    status ENUM('PENDING', 'PREPARING', 'READY', 'DELIVERING', 'COMPLETED', 'CANCELED') DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (shop_id) REFERENCES canteen_shops(id),
    FOREIGN KEY (buyer_id) REFERENCES users(id),
    FOREIGN KEY (wallet_ledger_id) REFERENCES wallet_ledgers(id)
);

CREATE TABLE canteen_order_items (
    id CHAR(36) PRIMARY KEY,
    order_id CHAR(36),
    item_id CHAR(36),
    quantity INT NOT NULL,
    price_at_purchase DECIMAL(15,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES canteen_orders(id),
    FOREIGN KEY (item_id) REFERENCES canteen_items(id)
);

-- ==========================================
-- 18. GATE PASS (SURAT IZIN KELUAR)
-- ==========================================
CREATE TABLE gate_pass_settings (
    id CHAR(36) PRIMARY KEY,
    tenant_id CHAR(36) UNIQUE,
    level_1_role_id CHAR(36),
    level_2_role_id CHAR(36),
    level_3_role_id CHAR(36),
    main_approver_role_id CHAR(36),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id),
    FOREIGN KEY (level_1_role_id) REFERENCES roles(id),
    FOREIGN KEY (level_2_role_id) REFERENCES roles(id),
    FOREIGN KEY (level_3_role_id) REFERENCES roles(id),
    FOREIGN KEY (main_approver_role_id) REFERENCES roles(id)
);

CREATE TABLE gate_passes (
    id CHAR(36) PRIMARY KEY,
    tenant_id CHAR(36),
    student_id CHAR(36),
    reason TEXT NOT NULL,
    expected_exit_time TIMESTAMP NOT NULL,
    expected_return_time TIMESTAMP NOT NULL,
    actual_exit_time TIMESTAMP,
    actual_return_time TIMESTAMP,
    exit_qr_token VARCHAR(255) UNIQUE,
    return_qr_token VARCHAR(255) UNIQUE,
    status ENUM('PENDING', 'APPROVED', 'EXITED', 'RETURNED', 'REJECTED', 'OVERDUE') DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id),
    FOREIGN KEY (student_id) REFERENCES users(id)
);

CREATE TABLE gate_pass_approvals (
    id CHAR(36) PRIMARY KEY,
    gate_pass_id CHAR(36),
    approver_role_id CHAR(36),
    tier_level INT NOT NULL,
    status ENUM('PENDING', 'APPROVED', 'REJECTED') DEFAULT 'PENDING',
    approved_by CHAR(36),
    approved_at TIMESTAMP,
    FOREIGN KEY (gate_pass_id) REFERENCES gate_passes(id),
    FOREIGN KEY (approver_role_id) REFERENCES roles(id),
    FOREIGN KEY (approved_by) REFERENCES users(id)
);

-- ==========================================
-- 19. PKL & BURSA KERJA
-- ==========================================
CREATE TABLE companies (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(36) REFERENCES tenants(id),
    name VARCHAR(255),
    industry VARCHAR(100),
    logo_url VARCHAR(255),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE TABLE job_vacancies (
    id VARCHAR(36) PRIMARY KEY,
    company_id VARCHAR(36) REFERENCES companies(id),
    title VARCHAR(255),
    type ENUM('PKL', 'MAGANG', 'FULL_TIME', 'PART_TIME', 'CONTRACT', 'FREELANCE'),
    arrangement ENUM('ON_SITE', 'HYBRID', 'REMOTE') DEFAULT 'ON_SITE',
    description TEXT,
    requirements TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE TABLE job_applications (
    id VARCHAR(36) PRIMARY KEY,
    job_vacancy_id VARCHAR(36) REFERENCES job_vacancies(id),
    student_id VARCHAR(36) REFERENCES users(id),
    resume_url VARCHAR(255),
    status ENUM('APPLIED', 'INTERVIEW', 'ACCEPTED', 'REJECTED') DEFAULT 'APPLIED',
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- ==========================================
-- 20. PORTOFOLIO SISWA
-- ==========================================
CREATE TABLE student_portfolios (
    id VARCHAR(36) PRIMARY KEY,
    student_id VARCHAR(36) REFERENCES users(id),
    title VARCHAR(255),
    description TEXT,
    project_url VARCHAR(255),
    thumbnail_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP
);

-- ==========================================
-- 21. PENGUMUMAN & KOMUNIKASI
-- ==========================================
CREATE TABLE announcements (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(36) REFERENCES tenants(id),
    title VARCHAR(255),
    content TEXT,
    type VARCHAR(50),
    target_audience VARCHAR(100),
    event_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP,
    updated_by VARCHAR(36) REFERENCES users(id)
);

CREATE TABLE direct_messages (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(36) REFERENCES tenants(id),
    sender_id VARCHAR(36) REFERENCES users(id),
    receiver_id VARCHAR(36) REFERENCES users(id),
    encrypted_content TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

-- ==========================================
-- 22. ETALASE & SPMB
-- ==========================================
CREATE TABLE school_facilities (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(36) REFERENCES tenants(id),
    name VARCHAR(255),
    description TEXT,
    photo_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE TABLE spmb_batches (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(36) REFERENCES tenants(id),
    name VARCHAR(255),
    description TEXT,
    start_date DATE,
    end_date DATE,
    is_active BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE TABLE spmb_batch_majors (
    id VARCHAR(36) PRIMARY KEY,
    spmb_batch_id VARCHAR(36) REFERENCES spmb_batches(id),
    major_id VARCHAR(36) REFERENCES majors(id),
    registration_fee DECIMAL(15,2) DEFAULT 0,
    re_registration_fee DECIMAL(15,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (spmb_batch_id, major_id)
);

CREATE TABLE spmb_registrations (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(36) REFERENCES tenants(id),
    parent_id VARCHAR(36) REFERENCES users(id),
    spmb_batch_id VARCHAR(36) REFERENCES spmb_batches(id),
    major_id VARCHAR(36) REFERENCES majors(id),
    second_major_id VARCHAR(36) REFERENCES majors(id),
    invoice_id VARCHAR(36) REFERENCES student_invoices(id),
    
    -- Student Details
    student_name VARCHAR(255),
    nisn VARCHAR(50),
    previous_school VARCHAR(255),
    region VARCHAR(255),
    gender ENUM('MALE', 'FEMALE'),
    religion VARCHAR(50),
    photo_url VARCHAR(255),
    student_phone VARCHAR(50),
    
    -- Parent Details
    father_name VARCHAR(255),
    mother_name VARCHAR(255),
    father_phone VARCHAR(50),
    mother_phone VARCHAR(50),
    father_job VARCHAR(100),
    mother_job VARCHAR(100),
    father_income VARCHAR(100),
    mother_income VARCHAR(100),
    
    -- Status & Exam
    registration_status ENUM('PENDING', 'DOCUMENT_REVIEW', 'TEST', 'ACCEPTED', 'REJECTED') DEFAULT 'PENDING',
    exam_schedule TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP,
    updated_by VARCHAR(36) REFERENCES users(id)
);

-- ==========================================
-- 23. INVENTARIS ASET
-- ==========================================
CREATE TABLE inventories (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(36) REFERENCES tenants(id),
    item_code VARCHAR(100) UNIQUE,
    name VARCHAR(255),
    category VARCHAR(100),
    quantity INT,
    condition ENUM('GOOD', 'DAMAGED', 'MAINTENANCE') DEFAULT 'GOOD',
    location VARCHAR(255),
    managed_by VARCHAR(36) REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP
);

-- ==========================================
-- 24. PERPUSTAKAAN (LIBRARY) & ARSIP ILMIAH
-- ==========================================
CREATE TABLE library_settings (
    tenant_id CHAR(36) PRIMARY KEY,
    archive_admin_staff_id CHAR(36),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    FOREIGN KEY (archive_admin_staff_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE books (
    id CHAR(36) PRIMARY KEY,
    tenant_id CHAR(36) NOT NULL,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255),
    isbn VARCHAR(50),
    cover_url VARCHAR(255),
    -- For physical books
    book_type ENUM('PHYSICAL', 'DIGITAL') NOT NULL,
    stock INT DEFAULT 0,
    is_negotiable_time BOOLEAN DEFAULT FALSE,
    max_borrow_days INT DEFAULT 7,
    late_fee_per_day DECIMAL(10,2) DEFAULT 0.00,
    -- For digital books
    file_url VARCHAR(500),
    payment_type ENUM('FREE', 'ONE_TIME', 'SUBSCRIPTION') DEFAULT 'FREE',
    price DECIMAL(10,2) DEFAULT 0.00,
    uploader_staff_id CHAR(36) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    FOREIGN KEY (uploader_staff_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE book_borrowings (
    id CHAR(36) PRIMARY KEY,
    tenant_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    book_id CHAR(36) NOT NULL,
    requested_start_date TIMESTAMP NOT NULL,
    requested_end_date TIMESTAMP NOT NULL,
    approved_start_date TIMESTAMP,
    approved_end_date TIMESTAMP,
    status ENUM('PENDING', 'APPROVED', 'BORROWED', 'RETURNED', 'REJECTED', 'OVERDUE') DEFAULT 'PENDING',
    borrow_qr_token VARCHAR(255),
    return_qr_token VARCHAR(255),
    actual_borrowed_at TIMESTAMP,
    actual_returned_at TIMESTAMP,
    late_fee_paid DECIMAL(10,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE
);

-- User access to paid digital books
CREATE TABLE digital_book_access (
    id CHAR(36) PRIMARY KEY,
    user_id CHAR(36) NOT NULL,
    book_id CHAR(36) NOT NULL,
    access_type ENUM('ONE_TIME', 'SUBSCRIPTION') NOT NULL,
    expires_at TIMESTAMP,
    granted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE,
    UNIQUE(user_id, book_id)
);

CREATE TABLE scientific_journals (
    id CHAR(36) PRIMARY KEY,
    tenant_id CHAR(36) NOT NULL,
    uploader_id CHAR(36) NOT NULL,
    title VARCHAR(255) NOT NULL,
    abstract TEXT,
    angkatan INT NOT NULL,
    kelas VARCHAR(50) NOT NULL,
    jurusan VARCHAR(100) NOT NULL,
    softcopy_url VARCHAR(500),
    scanner_url VARCHAR(500),
    status ENUM('PENDING', 'APPROVED', 'REJECTED') DEFAULT 'PENDING',
    approved_by CHAR(36),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    FOREIGN KEY (uploader_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (approved_by) REFERENCES users(id) ON DELETE SET NULL
);

-- ==========================================
-- 25. PKL MONITORING & PENILAIAN KEPALA SEKOLAH
-- ==========================================
CREATE TABLE performance_settings (
    tenant_id CHAR(36) PRIMARY KEY,
    principal_staff_id CHAR(36),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    FOREIGN KEY (principal_staff_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE pkl_monitorings (
    id CHAR(36) PRIMARY KEY,
    tenant_id CHAR(36) NOT NULL,
    student_id CHAR(36) NOT NULL,
    supervisor_staff_id CHAR(36) NOT NULL,
    documentation_url VARCHAR(500),
    notes TEXT,
    status ENUM('PENDING', 'APPROVED', 'REJECTED') DEFAULT 'PENDING',
    principal_score DECIMAL(5,2),
    principal_notes TEXT,
    evaluated_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (supervisor_staff_id) REFERENCES users(id) ON DELETE CASCADE
);
CREATE TABLE pkl_mentorships (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(36) NOT NULL,
    academic_year_id VARCHAR(36) NOT NULL,
    student_id VARCHAR(36) NOT NULL UNIQUE,
    mentor_id VARCHAR(36) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE pkl_mentoring_schedules (
    id VARCHAR(36) PRIMARY KEY,
    mentorship_id VARCHAR(36) NOT NULL REFERENCES pkl_mentorships(id),
    schedule_date DATE NOT NULL,
    zoom_link TEXT,
    mentor_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE pkl_journals (
    id VARCHAR(36) PRIMARY KEY,
    schedule_id VARCHAR(36) NOT NULL REFERENCES pkl_mentoring_schedules(id),
    description TEXT,
    document_urls TEXT, 
    status VARCHAR(20) DEFAULT 'PENDING',
    feedback TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE pkl_final_report_settings (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(36) NOT NULL,
    target_type VARCHAR(20) NOT NULL,
    target_id VARCHAR(36),
    start_date TIMESTAMP,
    end_date TIMESTAMP
);

CREATE TABLE pkl_final_reports (
    id VARCHAR(36) PRIMARY KEY,
    student_id VARCHAR(36) NOT NULL,
    document_url TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'PENDING',
    notes TEXT,
    approved_by VARCHAR(36),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);
-- ==========================================
-- 20. CANTEEN ENHANCEMENTS (BOM, DISCOUNTS, DELIVERY)
-- ==========================================
ALTER TABLE canteen_shops ADD COLUMN IF NOT EXISTS allow_delivery BOOLEAN DEFAULT FALSE;
ALTER TABLE canteen_shops ADD COLUMN IF NOT EXISTS base_delivery_fee DECIMAL(15,2) DEFAULT 0;

ALTER TABLE canteen_orders ADD COLUMN IF NOT EXISTS delivery_method VARCHAR(50) DEFAULT 'PICKUP';
ALTER TABLE canteen_orders ADD COLUMN IF NOT EXISTS preorder_date DATE;

CREATE TABLE IF NOT EXISTS canteen_item_ingredients (
    id CHAR(36) PRIMARY KEY,
    item_id CHAR(36) NOT NULL,
    name VARCHAR(255) NOT NULL,
    cost DECIMAL(15,2) NOT NULL,
    quantity DECIMAL(10,2) DEFAULT 1,
    unit VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (item_id) REFERENCES canteen_items(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS canteen_discounts (
    id CHAR(36) PRIMARY KEY,
    shop_id CHAR(36) NOT NULL,
    item_id CHAR(36), -- If NULL, applies to all items in shop
    discount_type VARCHAR(50) NOT NULL, -- PERCENTAGE or FIXED_AMOUNT
    value DECIMAL(15,2) NOT NULL,
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    max_uses INT,
    current_uses INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (shop_id) REFERENCES canteen_shops(id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES canteen_items(id) ON DELETE CASCADE
);

-- ==========================================
-- 21. AI FEATURE CONTROL ENHANCEMENTS
-- ==========================================
INSERT INTO permissions (id, name) VALUES ('p-012', 'MANAGE_AI') ON CONFLICT DO NOTHING;

ALTER TABLE ai_module_settings ADD COLUMN IF NOT EXISTS monthly_limit INT DEFAULT 0; -- 0 = unlimited
ALTER TABLE ai_module_settings ADD COLUMN IF NOT EXISTS daily_limit INT DEFAULT 0;   -- 0 = unlimited
ALTER TABLE ai_module_settings ADD COLUMN IF NOT EXISTS monthly_used INT DEFAULT 0;
ALTER TABLE ai_module_settings ADD COLUMN IF NOT EXISTS daily_used INT DEFAULT 0;
ALTER TABLE ai_module_settings ADD COLUMN IF NOT EXISTS last_reset_date DATE;
ALTER TABLE ai_module_settings ADD COLUMN IF NOT EXISTS id VARCHAR(36);

-- Seed default AI module settings for existing tenants (idempotent)
-- Modules: HEALTH, CANTEEN, ACADEMIC_REPORT, VIOLATIONS

-- ==========================================
-- 22. VIEWS (PERFORMANCE OPTIMIZATION)
-- ==========================================

CREATE VIEW IF NOT EXISTS vw_student_leaderboard AS
WITH student_averages AS (
    SELECT
        rc.tenant_id,
        rc.term_id,
        rc.student_id,
        AVG(rcg.score) AS average_score
    FROM report_cards rc
    JOIN report_card_grades rcg ON rcg.report_card_id = rc.id
    GROUP BY rc.tenant_id, rc.term_id, rc.student_id
)
SELECT
    sa.tenant_id,
    sa.term_id,
    sa.student_id,
    u.name AS student_name,
    u.identifier AS nisn,
    c.id AS class_id,
    c.name AS class_name,
    m.id AS major_id,
    COALESCE(m.name, '') AS major_name,
    c.grade_level,
    sa.average_score,
    RANK() OVER (PARTITION BY sa.tenant_id, sa.term_id ORDER BY sa.average_score DESC) AS rank
FROM student_averages sa
JOIN users u ON u.id = sa.student_id
JOIN classes c ON c.id = u.class_id
LEFT JOIN majors m ON m.id = c.major_id;

-- ==========================================
-- 23. WebTorrent Metadata
-- ==========================================
CREATE TABLE IF NOT EXISTS torrent_metadata (
    file_path VARCHAR(500) PRIMARY KEY,
    info_hash VARCHAR(40) NOT NULL,
    magnet_link TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
