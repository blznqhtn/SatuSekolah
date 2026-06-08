-- ==========================================
-- 3. GATE PASS (SURAT IZIN KELUAR)
-- ==========================================
DROP TABLE IF EXISTS gate_pass_approvals;
DROP TABLE IF EXISTS gate_passes;
DROP TABLE IF EXISTS gate_pass_settings;
DROP TYPE IF EXISTS gate_pass_status;

-- ==========================================
-- 2. DIGITAL CANTEEN
-- ==========================================
DROP TABLE IF EXISTS canteen_order_items;
DROP TABLE IF EXISTS canteen_orders;
DROP TABLE IF EXISTS canteen_carts;
DROP TABLE IF EXISTS canteen_items;
DROP TABLE IF EXISTS canteen_shops;
DROP TYPE IF EXISTS canteen_order_status;

-- ==========================================
-- 1. AI TOKEN SPLIT & MODULE SETTINGS
-- ==========================================
DROP TABLE IF EXISTS ai_module_settings;

-- Drop tables in reverse order of dependencies
DROP TABLE IF EXISTS inventories;
DROP TABLE IF EXISTS direct_messages;
DROP TABLE IF EXISTS spmb_registrations;
DROP TABLE IF EXISTS spmb_batches;
DROP TABLE IF EXISTS school_facilities;
DROP TABLE IF EXISTS announcements;
DROP TABLE IF EXISTS student_portfolios;
DROP TABLE IF EXISTS job_applications;
DROP TABLE IF EXISTS job_vacancies;
DROP TABLE IF EXISTS companies;
DROP TABLE IF EXISTS report_card_grades;
DROP TABLE IF EXISTS report_cards;
DROP TABLE IF EXISTS academic_terms;
DROP TABLE IF EXISTS class_schedules;
DROP TABLE IF EXISTS student_violations;
DROP TABLE IF EXISTS violation_types;
DROP TABLE IF EXISTS e_journals;
DROP TABLE IF EXISTS book_borrowings;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS invoice_payments;
DROP TABLE IF EXISTS student_invoices;
DROP TABLE IF EXISTS fees;
DROP TABLE IF EXISTS fee_types;
DROP TABLE IF EXISTS form_answers;
DROP TABLE IF EXISTS form_responses;
DROP TABLE IF EXISTS form_questions;
DROP TABLE IF EXISTS dynamic_forms;
DROP TABLE IF EXISTS teacher_performances;
DROP TABLE IF EXISTS reimbursements;
DROP TABLE IF EXISTS ai_tenant_quotas;
DROP TABLE IF EXISTS health_records;
DROP TABLE IF EXISTS student_answers;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS quizzes;
DROP TABLE IF EXISTS modules;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS leave_approvals;
DROP TABLE IF EXISTS leave_requests;
DROP TABLE IF EXISTS attendances;
DROP TABLE IF EXISTS attendance_settings;
DROP TABLE IF EXISTS wallet_ledgers;
DROP TABLE IF EXISTS payout_methods;
DROP TABLE IF EXISTS user_roles;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS role_permissions;
DROP TABLE IF EXISTS permissions;
DROP TABLE IF EXISTS roles;
DROP TABLE IF EXISTS classes;
DROP TABLE IF EXISTS majors;
DROP TABLE IF EXISTS academic_years;
DROP TABLE IF EXISTS tenants;

-- Drop Enums
DROP TYPE IF EXISTS inventory_condition;
DROP TYPE IF EXISTS spmb_status;
DROP TYPE IF EXISTS job_app_status;
DROP TYPE IF EXISTS work_arrangement;
DROP TYPE IF EXISTS job_type;
DROP TYPE IF EXISTS journal_status;
DROP TYPE IF EXISTS borrowing_status;
DROP TYPE IF EXISTS invoice_status;
DROP TYPE IF EXISTS leave_status;
DROP TYPE IF EXISTS attendance_status;
DROP TYPE IF EXISTS transaction_type;
DROP TYPE IF EXISTS enrollment_status;
DROP TYPE IF EXISTS user_category;

