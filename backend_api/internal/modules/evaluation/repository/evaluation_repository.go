package repository

import (
	"context"
	"database/sql"
	"errors"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/evaluation/domain"
)

type evaluationRepository struct {
	db *sql.DB
}

func NewEvaluationRepository(db *sql.DB) domain.EvaluationRepository {
	return &evaluationRepository{db: db}
}

func (r *evaluationRepository) GetActivePeriod(ctx context.Context, tenantID uuid.UUID) (*domain.EvaluationPeriod, error) {
	q := `SELECT id, tenant_id, name, start_date, end_date, is_active FROM teacher_evaluation_periods WHERE tenant_id = ? AND is_active = true LIMIT 1`
	var p domain.EvaluationPeriod
	var startStr, endStr string
	err := r.db.QueryRowContext(ctx, q, tenantID).Scan(&p.ID, &p.TenantID, &p.Name, &startStr, &endStr, &p.IsActive)
	if err == sql.ErrNoRows {
		return nil, nil // No active period
	}
	if err != nil {
		return nil, err
	}
	return &p, nil
}

func (r *evaluationRepository) GetCategories(ctx context.Context, tenantID uuid.UUID) ([]*domain.EvaluationCategory, error) {
	q := `SELECT id, tenant_id, name, weight FROM teacher_evaluation_categories WHERE tenant_id = ?`
	rows, err := r.db.QueryContext(ctx, q, tenantID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var cats []*domain.EvaluationCategory
	for rows.Next() {
		var c domain.EvaluationCategory
		if err := rows.Scan(&c.ID, &c.TenantID, &c.Name, &c.Weight); err != nil {
			return nil, err
		}
		cats = append(cats, &c)
	}
	return cats, nil
}

func (r *evaluationRepository) GetEligibleTeachers(ctx context.Context, tenantID, studentID, periodID uuid.UUID) ([]*domain.TeacherEligibleDTO, error) {
	// Teachers for a student:
	// Find class_id for student
	var classIDStr sql.NullString
	err := r.db.QueryRowContext(ctx, "SELECT class_id FROM users WHERE id = ?", studentID).Scan(&classIDStr)
	if err != nil || !classIDStr.Valid {
		return nil, errors.New("student does not have a valid class")
	}

	// 1. Wali Kelas
	// 2. Guru Mata Pelajaran (dari class_schedules)
	q := `
		SELECT DISTINCT u.id, u.name, COALESCE(c.name, 'Wali Kelas') as course_name
		FROM users u
		LEFT JOIN classes cl ON cl.homeroom_teacher_id = u.id AND cl.id = ?
		LEFT JOIN class_schedules cs ON cs.staff_id = u.id AND cs.class_id = ?
		LEFT JOIN courses c ON cs.course_id = c.id
		WHERE u.tenant_id = ? AND (cl.id IS NOT NULL OR cs.id IS NOT NULL)
	`
	rows, err := r.db.QueryContext(ctx, q, classIDStr.String, classIDStr.String, tenantID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var teachers []*domain.TeacherEligibleDTO
	for rows.Next() {
		var t domain.TeacherEligibleDTO
		if err := rows.Scan(&t.ID, &t.Name, &t.Course); err != nil {
			return nil, err
		}
		
		// Check if already graded
		var graded int
		errCheck := r.db.QueryRowContext(ctx, 
			"SELECT 1 FROM teacher_evaluation_submissions WHERE period_id = ? AND teacher_id = ? AND evaluator_id = ?", 
			periodID, t.ID, studentID,
		).Scan(&graded)
		if errCheck == nil {
			t.IsGraded = true
		}
		
		teachers = append(teachers, &t)
	}
	return teachers, nil
}

func (r *evaluationRepository) HasSubmitted(ctx context.Context, periodID, teacherID, evaluatorID uuid.UUID) (bool, error) {
	var count int
	err := r.db.QueryRowContext(ctx, 
		"SELECT COUNT(*) FROM teacher_evaluation_submissions WHERE period_id = ? AND teacher_id = ? AND evaluator_id = ?",
		periodID, teacherID, evaluatorID,
	).Scan(&count)
	if err != nil {
		return false, err
	}
	return count > 0, nil
}

func (r *evaluationRepository) SaveSubmission(ctx context.Context, sub *domain.EvaluationSubmission) error {
	q := `INSERT INTO teacher_evaluation_submissions (id, tenant_id, period_id, teacher_id, evaluator_id) VALUES (?, ?, ?, ?, ?)`
	_, err := r.db.ExecContext(ctx, q, sub.ID, sub.TenantID, sub.PeriodID, sub.TeacherID, sub.EvaluatorID)
	return err
}

func (r *evaluationRepository) SaveScores(ctx context.Context, tenantID, periodID, teacherID uuid.UUID, scores []domain.CategoryScore) error {
	q := `INSERT INTO teacher_evaluation_scores (id, tenant_id, period_id, teacher_id, category_id, score) VALUES (?, ?, ?, ?, ?, ?)`
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}

	for _, s := range scores {
		id := uuid.New()
		if _, err := tx.ExecContext(ctx, q, id, tenantID, periodID, teacherID, s.CategoryID, s.Score); err != nil {
			tx.Rollback()
			return err
		}
	}
	return tx.Commit()
}

func (r *evaluationRepository) SaveComment(ctx context.Context, tenantID, periodID, teacherID uuid.UUID, adv, dis, sug string) error {
	if adv == "" && dis == "" && sug == "" {
		return nil
	}
	id := uuid.New()
	q := `INSERT INTO teacher_evaluation_comments (id, tenant_id, period_id, teacher_id, advantages, disadvantages, suggestions) VALUES (?, ?, ?, ?, ?, ?, ?)`
	_, err := r.db.ExecContext(ctx, q, id, tenantID, periodID, teacherID, adv, dis, sug)
	return err
}

func (r *evaluationRepository) GetTeacherResults(ctx context.Context, tenantID, periodID, teacherID uuid.UUID) (*domain.EvaluationResultDTO, error) {
	res := &domain.EvaluationResultDTO{
		TeacherID: teacherID,
		CategoryAverages: make(map[uuid.UUID]float64),
	}
	
	// Get teacher name
	r.db.QueryRowContext(ctx, "SELECT name FROM users WHERE id = ?", teacherID).Scan(&res.TeacherName)
	
	// Count total submissions
	r.db.QueryRowContext(ctx, "SELECT COUNT(*) FROM teacher_evaluation_submissions WHERE period_id = ? AND teacher_id = ?", periodID, teacherID).Scan(&res.TotalEvaluators)
	
	// Get averages
	qAvg := `
		SELECT category_id, AVG(score) 
		FROM teacher_evaluation_scores 
		WHERE period_id = ? AND teacher_id = ?
		GROUP BY category_id
	`
	rows, err := r.db.QueryContext(ctx, qAvg, periodID, teacherID)
	if err == nil {
		defer rows.Close()
		var total float64
		var count int
		for rows.Next() {
			var catID uuid.UUID
			var avgScore float64
			if err := rows.Scan(&catID, &avgScore); err == nil {
				res.CategoryAverages[catID] = avgScore
				total += avgScore
				count++
			}
		}
		if count > 0 {
			res.AverageScore = total / float64(count)
		}
	}
	
	// Get comments
	qComm := `
		SELECT advantages, disadvantages, suggestions 
		FROM teacher_evaluation_comments 
		WHERE period_id = ? AND teacher_id = ?
	`
	rowsC, err := r.db.QueryContext(ctx, qComm, periodID, teacherID)
	if err == nil {
		defer rowsC.Close()
		for rowsC.Next() {
			var c domain.EvaluationCommentResult
			var adv, dis, sug sql.NullString
			if err := rowsC.Scan(&adv, &dis, &sug); err == nil {
				if adv.Valid { c.Advantages = adv.String }
				if dis.Valid { c.Disadvantages = dis.String }
				if sug.Valid { c.Suggestions = sug.String }
				res.Comments = append(res.Comments, c)
			}
		}
	}
	
	return res, nil
}
