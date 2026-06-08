package repository

import (
	"context"
	"database/sql"
	"time"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/pkg/domain"
)

type pkgRepository struct {
	db *sql.DB
	tx *sql.Tx
}

func NewPkgRepository(db *sql.DB) domain.PkgRepository {
	return &pkgRepository{db: db}
}

func (r *pkgRepository) ExecTx(ctx context.Context, fn func(repo domain.PkgRepository) error) error {
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	txRepo := &pkgRepository{db: r.db, tx: tx}
	if err := fn(txRepo); err != nil {
		_ = tx.Rollback()
		return err
	}
	return tx.Commit()
}

func (r *pkgRepository) queryRow(ctx context.Context, query string, args ...interface{}) *sql.Row {
	if r.tx != nil {
		return r.tx.QueryRowContext(ctx, query, args...)
	}
	return r.db.QueryRowContext(ctx, query, args...)
}

func (r *pkgRepository) exec(ctx context.Context, query string, args ...interface{}) (sql.Result, error) {
	if r.tx != nil {
		return r.tx.ExecContext(ctx, query, args...)
	}
	return r.db.ExecContext(ctx, query, args...)
}

func (r *pkgRepository) query(ctx context.Context, query string, args ...interface{}) (*sql.Rows, error) {
	if r.tx != nil {
		return r.tx.QueryContext(ctx, query, args...)
	}
	return r.db.QueryContext(ctx, query, args...)
}

// ==========================================
// PERIODS
// ==========================================

func (r *pkgRepository) CreatePeriod(ctx context.Context, period *domain.PkgPeriod) error {
	if period.ID == uuid.Nil {
		period.ID = uuid.New()
	}
	period.CreatedAt = time.Now()
	q := `INSERT INTO pkg_periods (id, tenant_id, name, start_date, end_date, is_active, created_at) VALUES ($1, $2, $3, $4, $5, $6, $7)`
	_, err := r.exec(ctx, q, period.ID, period.TenantID, period.Name, period.StartDate, period.EndDate, period.IsActive, period.CreatedAt)
	return err
}

func (r *pkgRepository) GetPeriods(ctx context.Context, tenantID uuid.UUID) ([]*domain.PkgPeriod, error) {
	q := `SELECT id, tenant_id, name, start_date, end_date, is_active, created_at FROM pkg_periods WHERE tenant_id = $1 ORDER BY start_date DESC`
	rows, err := r.query(ctx, q, tenantID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var periods []*domain.PkgPeriod
	for rows.Next() {
		var p domain.PkgPeriod
		if err := rows.Scan(&p.ID, &p.TenantID, &p.Name, &p.StartDate, &p.EndDate, &p.IsActive, &p.CreatedAt); err != nil {
			return nil, err
		}
		periods = append(periods, &p)
	}
	return periods, nil
}

func (r *pkgRepository) GetActivePeriod(ctx context.Context, tenantID uuid.UUID) (*domain.PkgPeriod, error) {
	q := `SELECT id, tenant_id, name, start_date, end_date, is_active, created_at FROM pkg_periods WHERE tenant_id = $1 AND is_active = TRUE LIMIT 1`
	var p domain.PkgPeriod
	err := r.queryRow(ctx, q, tenantID).Scan(&p.ID, &p.TenantID, &p.Name, &p.StartDate, &p.EndDate, &p.IsActive, &p.CreatedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return &p, err
}

// ==========================================
// INDICATORS
// ==========================================

func (r *pkgRepository) CreateIndicator(ctx context.Context, indicator *domain.PkgIndicator) error {
	if indicator.ID == uuid.Nil {
		indicator.ID = uuid.New()
	}
	indicator.CreatedAt = time.Now()
	q := `INSERT INTO pkg_indicators (id, tenant_id, name, description, weight, is_applicable_to_all, created_at) VALUES ($1, $2, $3, $4, $5, $6, $7)`
	_, err := r.exec(ctx, q, indicator.ID, indicator.TenantID, indicator.Name, indicator.Description, indicator.Weight, indicator.IsApplicableToAll, indicator.CreatedAt)
	return err
}

func (r *pkgRepository) GetIndicators(ctx context.Context, tenantID uuid.UUID) ([]*domain.PkgIndicator, error) {
	q := `SELECT id, tenant_id, name, description, weight, is_applicable_to_all, created_at FROM pkg_indicators WHERE tenant_id = $1 ORDER BY created_at ASC`
	rows, err := r.query(ctx, q, tenantID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var indicators []*domain.PkgIndicator
	for rows.Next() {
		var ind domain.PkgIndicator
		if err := rows.Scan(&ind.ID, &ind.TenantID, &ind.Name, &ind.Description, &ind.Weight, &ind.IsApplicableToAll, &ind.CreatedAt); err != nil {
			return nil, err
		}
		indicators = append(indicators, &ind)
	}
	return indicators, nil
}

// ==========================================
// SUBMISSIONS
// ==========================================

func (r *pkgRepository) CreateSubmission(ctx context.Context, submission *domain.PkgSubmission) error {
	if submission.ID == uuid.Nil {
		submission.ID = uuid.New()
	}
	submission.SubmittedAt = time.Now()
	q := `INSERT INTO pkg_submissions (id, period_id, indicator_id, staff_id, document_url, description, submitted_at) VALUES ($1, $2, $3, $4, $5, $6, $7)`
	_, err := r.exec(ctx, q, submission.ID, submission.PeriodID, submission.IndicatorID, submission.StaffID, submission.DocumentURL, submission.Description, submission.SubmittedAt)
	return err
}

func (r *pkgRepository) GetSubmissionsByTeacherAndPeriod(ctx context.Context, StaffID, periodID uuid.UUID) ([]*domain.PkgSubmission, error) {
	q := `SELECT id, period_id, indicator_id, staff_id, document_url, description, submitted_at FROM pkg_submissions WHERE staff_id = $1 AND period_id = $2 ORDER BY submitted_at DESC`
	rows, err := r.query(ctx, q, StaffID, periodID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var subs []*domain.PkgSubmission
	for rows.Next() {
		var s domain.PkgSubmission
		if err := rows.Scan(&s.ID, &s.PeriodID, &s.IndicatorID, &s.StaffID, &s.DocumentURL, &s.Description, &s.SubmittedAt); err != nil {
			return nil, err
		}
		subs = append(subs, &s)
	}
	return subs, nil
}

func (r *pkgRepository) GetSubmissionByID(ctx context.Context, submissionID uuid.UUID) (*domain.PkgSubmission, error) {
	q := `SELECT id, period_id, indicator_id, staff_id, document_url, description, submitted_at FROM pkg_submissions WHERE id = $1`
	var s domain.PkgSubmission
	err := r.queryRow(ctx, q, submissionID).Scan(&s.ID, &s.PeriodID, &s.IndicatorID, &s.StaffID, &s.DocumentURL, &s.Description, &s.SubmittedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return &s, err
}

// ==========================================
// EVALUATIONS
// ==========================================

func (r *pkgRepository) CreateEvaluation(ctx context.Context, evaluation *domain.PkgEvaluation) error {
	if evaluation.ID == uuid.Nil {
		evaluation.ID = uuid.New()
	}
	evaluation.EvaluatedAt = time.Now()
	q := `INSERT INTO pkg_evaluations (id, submission_id, evaluator_id, score, comments, evaluated_at) VALUES ($1, $2, $3, $4, $5, $6)`
	_, err := r.exec(ctx, q, evaluation.ID, evaluation.SubmissionID, evaluation.EvaluatorID, evaluation.Score, evaluation.Comments, evaluation.EvaluatedAt)
	return err
}

func (r *pkgRepository) GetEvaluationsBySubmission(ctx context.Context, submissionID uuid.UUID) ([]*domain.PkgEvaluation, error) {
	q := `SELECT id, submission_id, evaluator_id, score, comments, evaluated_at FROM pkg_evaluations WHERE submission_id = $1`
	rows, err := r.query(ctx, q, submissionID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var evals []*domain.PkgEvaluation
	for rows.Next() {
		var e domain.PkgEvaluation
		if err := rows.Scan(&e.ID, &e.SubmissionID, &e.EvaluatorID, &e.Score, &e.Comments, &e.EvaluatedAt); err != nil {
			return nil, err
		}
		evals = append(evals, &e)
	}
	return evals, nil
}

// ==========================================
// FAIR AVERAGING (Key business logic in SQL)
// ==========================================

// GetTeacherFairAverage calculates the weighted average score for a Staff
// across ONLY the indicators that are applicable to them (is_applicable_to_all=true)
// OR for which they have actually submitted documents.
// This ensures Staffs who don't teach classes aren't penalized for missing
// "dokumentasi pembelajaran" or "tugas siswa" indicators.
func (r *pkgRepository) GetTeacherFairAverage(ctx context.Context, StaffID, periodID uuid.UUID) (*domain.FairAverageResult, error) {
	q := `
		SELECT
			s.staff_id,
			s.period_id,
			COALESCE(SUM(i.weight), 0) AS total_weight,
			COALESCE(SUM(e.score * i.weight), 0) AS weighted_score,
			COUNT(DISTINCT s.id) AS total_submissions
		FROM pkg_submissions s
		JOIN pkg_indicators i ON s.indicator_id = i.id
		LEFT JOIN pkg_evaluations e ON e.submission_id = s.id
		WHERE s.staff_id = $1 AND s.period_id = $2
		GROUP BY s.staff_id, s.period_id
	`
	var result domain.FairAverageResult
	result.StaffID = StaffID
	result.PeriodID = periodID

	err := r.queryRow(ctx, q, StaffID, periodID).Scan(
		&result.StaffID,
		&result.PeriodID,
		&result.TotalWeight,
		&result.WeightedScore,
		&result.TotalSubmissions,
	)
	if err == sql.ErrNoRows {
		result.FinalAverage = 0
		return &result, nil
	}
	if err != nil {
		return nil, err
	}

	if result.TotalWeight > 0 {
		result.FinalAverage = result.WeightedScore / result.TotalWeight
	}
	return &result, nil
}
