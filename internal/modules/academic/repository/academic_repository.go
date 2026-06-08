package repository

import (
	"context"
	"database/sql"
	"time"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/academic/domain"
)

type academicRepository struct {
	db *sql.DB
	tx *sql.Tx
}

func NewAcademicRepository(db *sql.DB) domain.AcademicRepository {
	return &academicRepository{db: db}
}

func (r *academicRepository) ExecTx(ctx context.Context, fn func(repo domain.AcademicRepository) error) error {
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	txRepo := &academicRepository{db: r.db, tx: tx}
	if err := fn(txRepo); err != nil {
		_ = tx.Rollback()
		return err
	}
	return tx.Commit()
}

func (r *academicRepository) exec(ctx context.Context, q string, args ...interface{}) (sql.Result, error) {
	if r.tx != nil {
		return r.tx.ExecContext(ctx, q, args...)
	}
	return r.db.ExecContext(ctx, q, args...)
}

func (r *academicRepository) queryRow(ctx context.Context, q string, args ...interface{}) *sql.Row {
	if r.tx != nil {
		return r.tx.QueryRowContext(ctx, q, args...)
	}
	return r.db.QueryRowContext(ctx, q, args...)
}

func (r *academicRepository) query(ctx context.Context, q string, args ...interface{}) (*sql.Rows, error) {
	if r.tx != nil {
		return r.tx.QueryContext(ctx, q, args...)
	}
	return r.db.QueryContext(ctx, q, args...)
}

// ==========================================
// COURSES
// ==========================================

func (r *academicRepository) CreateCourse(ctx context.Context, course *domain.Course) error {
	if course.ID == uuid.Nil {
		course.ID = uuid.New()
	}
	course.CreatedAt = time.Now()
	q := `INSERT INTO courses (id, tenant_id, name, staff_id, created_at) VALUES ($1, $2, $3, $4, $5)`
	_, err := r.exec(ctx, q, course.ID, course.TenantID, course.Name, course.StaffID, course.CreatedAt)
	return err
}

func (r *academicRepository) GetCourses(ctx context.Context, tenantID uuid.UUID) ([]*domain.Course, error) {
	q := `SELECT id, tenant_id, name, staff_id, created_at FROM courses WHERE tenant_id = $1 AND deleted_at IS NULL ORDER BY created_at DESC`
	rows, err := r.query(ctx, q, tenantID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var courses []*domain.Course
	for rows.Next() {
		var c domain.Course
		if err := rows.Scan(&c.ID, &c.TenantID, &c.Name, &c.StaffID, &c.CreatedAt); err != nil {
			return nil, err
		}
		courses = append(courses, &c)
	}
	return courses, nil
}

// ==========================================
// MODULES
// ==========================================

func (r *academicRepository) CreateModule(ctx context.Context, module *domain.CourseModule) error {
	if module.ID == uuid.Nil {
		module.ID = uuid.New()
	}
	module.CreatedAt = time.Now()
	q := `INSERT INTO modules (id, course_id, title, content, created_at) VALUES ($1, $2, $3, $4, $5)`
	_, err := r.exec(ctx, q, module.ID, module.CourseID, module.Title, module.Content, module.CreatedAt)
	return err
}

func (r *academicRepository) GetModulesByCourse(ctx context.Context, courseID uuid.UUID) ([]*domain.CourseModule, error) {
	q := `SELECT id, course_id, title, content, created_at FROM modules WHERE course_id = $1 AND deleted_at IS NULL ORDER BY created_at ASC`
	rows, err := r.query(ctx, q, courseID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var modules []*domain.CourseModule
	for rows.Next() {
		var m domain.CourseModule
		if err := rows.Scan(&m.ID, &m.CourseID, &m.Title, &m.Content, &m.CreatedAt); err != nil {
			return nil, err
		}
		modules = append(modules, &m)
	}
	return modules, nil
}

// ==========================================
// SUBMISSIONS
// ==========================================

func (r *academicRepository) CreateSubmission(ctx context.Context, sub *domain.Submission) error {
	if sub.ID == uuid.Nil {
		sub.ID = uuid.New()
	}
	sub.SubmittedAt = time.Now()
	q := `INSERT INTO student_submissions (id, module_id, student_id, file_url, notes, submitted_at) VALUES ($1, $2, $3, $4, $5, $6)`
	_, err := r.exec(ctx, q, sub.ID, sub.ModuleID, sub.StudentID, sub.FileURL, sub.Notes, sub.SubmittedAt)
	return err
}

func (r *academicRepository) GetSubmissionsByModule(ctx context.Context, moduleID uuid.UUID) ([]*domain.Submission, error) {
	q := `SELECT id, module_id, student_id, file_url, notes, score, graded_by, graded_at, submitted_at FROM student_submissions WHERE module_id = $1 ORDER BY submitted_at DESC`
	rows, err := r.query(ctx, q, moduleID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var subs []*domain.Submission
	for rows.Next() {
		var s domain.Submission
		if err := rows.Scan(&s.ID, &s.ModuleID, &s.StudentID, &s.FileURL, &s.Notes, &s.Score, &s.GradedBy, &s.GradedAt, &s.SubmittedAt); err != nil {
			return nil, err
		}
		subs = append(subs, &s)
	}
	return subs, nil
}

func (r *academicRepository) GradeSubmission(ctx context.Context, submissionID uuid.UUID, score float64, gradedBy uuid.UUID) error {
	now := time.Now()
	q := `UPDATE student_submissions SET score = $1, graded_by = $2, graded_at = $3 WHERE id = $4`
	_, err := r.exec(ctx, q, score, gradedBy, now, submissionID)
	return err
}

// ==========================================
// ASSIGNMENT TARGETS
// ==========================================

func (r *academicRepository) CreateAssignmentTarget(ctx context.Context, target *domain.AssignmentTarget) error {
	if target.ID == uuid.Nil {
		target.ID = uuid.New()
	}
	target.CreatedAt = time.Now()
	q := `INSERT INTO assignment_targets (id, source_type, source_id, target_type, target_id, created_at) VALUES ($1, $2, $3, $4, $5, $6)`
	_, err := r.exec(ctx, q, target.ID, target.SourceType, target.SourceID, target.TargetType, target.TargetID, target.CreatedAt)
	return err
}

func (r *academicRepository) GetTargetsForSource(ctx context.Context, sourceType domain.SourceType, sourceID uuid.UUID) ([]*domain.AssignmentTarget, error) {
	q := `SELECT id, source_type, source_id, target_type, target_id, created_at FROM assignment_targets WHERE source_type = $1 AND source_id = $2`
	rows, err := r.query(ctx, q, sourceType, sourceID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var targets []*domain.AssignmentTarget
	for rows.Next() {
		var t domain.AssignmentTarget
		if err := rows.Scan(&t.ID, &t.SourceType, &t.SourceID, &t.TargetType, &t.TargetID, &t.CreatedAt); err != nil {
			return nil, err
		}
		targets = append(targets, &t)
	}
	return targets, nil
}
