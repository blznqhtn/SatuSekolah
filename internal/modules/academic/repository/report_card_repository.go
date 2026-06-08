package repository

import (
	"context"
	"database/sql"
	"fmt"
	"strings"
	"time"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/academic/domain"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/academic/entities"
)

type reportCardRepository struct {
	db *sql.DB
	tx *sql.Tx
}

func NewReportCardRepository(db *sql.DB) domain.ReportCardRepository {
	return &reportCardRepository{db: db}
}

func (r *reportCardRepository) ExecTx(ctx context.Context, fn func(repo domain.ReportCardRepository) error) error {
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	txRepo := &reportCardRepository{db: r.db, tx: tx}
	if err := fn(txRepo); err != nil {
		_ = tx.Rollback()
		return err
	}
	return tx.Commit()
}

func (r *reportCardRepository) exec(ctx context.Context, q string, args ...interface{}) (sql.Result, error) {
	if r.tx != nil {
		return r.tx.ExecContext(ctx, q, args...)
	}
	return r.db.ExecContext(ctx, q, args...)
}

func (r *reportCardRepository) queryRow(ctx context.Context, q string, args ...interface{}) *sql.Row {
	if r.tx != nil {
		return r.tx.QueryRowContext(ctx, q, args...)
	}
	return r.db.QueryRowContext(ctx, q, args...)
}

func (r *reportCardRepository) query(ctx context.Context, q string, args ...interface{}) (*sql.Rows, error) {
	if r.tx != nil {
		return r.tx.QueryContext(ctx, q, args...)
	}
	return r.db.QueryContext(ctx, q, args...)
}

// SaveReportCard inserts or updates a report card
func (r *reportCardRepository) SaveReportCard(ctx context.Context, rc *entities.ReportCard) error {
	if rc.ID == uuid.Nil {
		rc.ID = uuid.New()
	}
	rc.UpdatedAt = sql.NullTime{Time: time.Now(), Valid: true}

	q := `
		INSERT INTO report_cards (id, tenant_id, term_id, student_id, class_rank, homeroom_notes, created_at, updated_at, updated_by)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
		ON CONFLICT (id) DO UPDATE SET
			class_rank = EXCLUDED.class_rank,
			homeroom_notes = EXCLUDED.homeroom_notes,
			updated_at = EXCLUDED.updated_at,
			updated_by = EXCLUDED.updated_by
	`
	_, err := r.exec(ctx, q, rc.ID, rc.TenantID, rc.TermID, rc.StudentID, rc.ClassRank, rc.HomeroomNotes, rc.CreatedAt, rc.UpdatedAt, rc.UpdatedBy)
	return err
}

// SaveReportCardGrades deletes old grades and inserts new ones
func (r *reportCardRepository) SaveReportCardGrades(ctx context.Context, grades []*entities.ReportCardGrade) error {
	if len(grades) == 0 {
		return nil
	}
	
	// Delete existing grades for this report card
	delQ := `DELETE FROM report_card_grades WHERE report_card_id = $1`
	_, err := r.exec(ctx, delQ, grades[0].ReportCardID)
	if err != nil {
		return err
	}

	for _, g := range grades {
		if g.ID == uuid.Nil {
			g.ID = uuid.New()
		}
		g.UpdatedAt = sql.NullTime{Time: time.Now(), Valid: true}
		insQ := `
			INSERT INTO report_card_grades (id, report_card_id, course_id, score, predicate, description, created_at, updated_at)
			VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
		`
		_, err := r.exec(ctx, insQ, g.ID, g.ReportCardID, g.CourseID, g.Score, g.Predicate, g.Description, g.CreatedAt, g.UpdatedAt)
		if err != nil {
			return err
		}
	}
	return nil
}

func (r *reportCardRepository) GetReportCardByStudentAndTerm(ctx context.Context, tenantID, studentID, termID uuid.UUID) (*entities.ReportCard, error) {
	q := `
		SELECT id, tenant_id, term_id, student_id, class_rank, homeroom_notes, created_at, updated_at, updated_by
		FROM report_cards
		WHERE tenant_id = $1 AND student_id = $2 AND term_id = $3
	`
	var rc entities.ReportCard
	err := r.queryRow(ctx, q, tenantID, studentID, termID).Scan(
		&rc.ID, &rc.TenantID, &rc.TermID, &rc.StudentID, &rc.ClassRank, &rc.HomeroomNotes, &rc.CreatedAt, &rc.UpdatedAt, &rc.UpdatedBy,
	)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return &rc, nil
}

// GetLeaderboard dynamically calculates ranking using RANK() window function
func (r *reportCardRepository) GetLeaderboard(ctx context.Context, tenantID uuid.UUID, termID uuid.UUID, filter domain.LeaderboardFilter, filterID *uuid.UUID) ([]*domain.LeaderboardRow, error) {
	// Base query using the new materialized view for much better performance
	baseQuery := `
		SELECT
			student_id,
			student_name,
			nisn,
			class_name,
			major_name,
			grade_level,
			average_score,
			rank
		FROM vw_student_leaderboard
		WHERE tenant_id = $1 AND term_id = $2
	`
	
	var args []interface{}
	args = append(args, tenantID, termID)
	argIdx := 3

	if filter == domain.LeaderboardClass && filterID != nil {
		baseQuery += fmt.Sprintf(` AND class_id = $%d`, argIdx)
		args = append(args, *filterID)
		argIdx++
	} else if filter == domain.LeaderboardMajor && filterID != nil {
		baseQuery += fmt.Sprintf(` AND major_id = $%d`, argIdx)
		args = append(args, *filterID)
		argIdx++
	} else if filter == domain.LeaderboardGrade && filterID != nil {
		baseQuery += fmt.Sprintf(` AND grade_level = (SELECT grade_level FROM classes WHERE id = $%d)`, argIdx)
		args = append(args, *filterID)
		argIdx++
	}

	baseQuery += ` ORDER BY rank ASC`

	rows, err := r.query(ctx, baseQuery, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var result []*domain.LeaderboardRow
	for rows.Next() {
		var row domain.LeaderboardRow
		if err := rows.Scan(&row.StudentID, &row.StudentName, &row.NISN, &row.ClassName, &row.MajorName, &row.GradeLevel, &row.AverageScore, &row.Rank); err != nil {
			return nil, err
		}
		result = append(result, &row)
	}
	return result, nil
}

// GetCourseByName returns a course matching the name (case insensitive)
func (r *reportCardRepository) GetCourseByName(ctx context.Context, tenantID uuid.UUID, courseName string) (*domain.Course, error) {
	q := `SELECT id, tenant_id, name, staff_id, created_at FROM courses WHERE tenant_id = $1 AND LOWER(name) = $2 LIMIT 1`
	var c domain.Course
	err := r.queryRow(ctx, q, tenantID, strings.ToLower(strings.TrimSpace(courseName))).Scan(&c.ID, &c.TenantID, &c.Name, &c.StaffID, &c.CreatedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return &c, nil
}

func (r *reportCardRepository) GetStudentByNISN(ctx context.Context, tenantID uuid.UUID, nisn string) (uuid.UUID, error) {
	q := `SELECT id FROM users WHERE tenant_id = $1 AND identifier = $2 LIMIT 1`
	var id uuid.UUID
	err := r.queryRow(ctx, q, tenantID, strings.TrimSpace(nisn)).Scan(&id)
	if err != nil {
		return uuid.Nil, err
	}
	return id, nil
}

func (r *reportCardRepository) GetStudentsByClass(ctx context.Context, tenantID, classID uuid.UUID) ([]struct{
	ID uuid.UUID
	Name string
	NISN string
}, error) {
	q := `SELECT id, name, identifier FROM users WHERE tenant_id = $1 AND class_id = $2 AND deleted_at IS NULL ORDER BY name ASC`
	rows, err := r.query(ctx, q, tenantID, classID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var result []struct{
		ID uuid.UUID
		Name string
		NISN string
	}
	for rows.Next() {
		var s struct{
			ID uuid.UUID
			Name string
			NISN string
		}
		if err := rows.Scan(&s.ID, &s.Name, &s.NISN); err != nil {
			return nil, err
		}
		result = append(result, s)
	}
	return result, nil
}


