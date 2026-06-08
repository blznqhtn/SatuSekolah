package repository

import (
	"context"
	"database/sql"
	"time"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/ai/domain"
)

type aiRepository struct {
	db *sql.DB
	tx *sql.Tx
}

func NewAIRepository(db *sql.DB) domain.AIRepository {
	return &aiRepository{db: db}
}

func (r *aiRepository) ExecTx(ctx context.Context, fn func(repo domain.AIRepository) error) error {
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	txRepo := &aiRepository{db: r.db, tx: tx}
	err = fn(txRepo)
	if err != nil {
		if rbErr := tx.Rollback(); rbErr != nil {
			return rbErr
		}
		return err
	}
	return tx.Commit()
}

func (r *aiRepository) queryRow(ctx context.Context, query string, args ...interface{}) *sql.Row {
	if r.tx != nil {
		return r.tx.QueryRowContext(ctx, query, args...)
	}
	return r.db.QueryRowContext(ctx, query, args...)
}

func (r *aiRepository) query(ctx context.Context, query string, args ...interface{}) (*sql.Rows, error) {
	if r.tx != nil {
		return r.tx.QueryContext(ctx, query, args...)
	}
	return r.db.QueryContext(ctx, query, args...)
}

func (r *aiRepository) exec(ctx context.Context, query string, args ...interface{}) (sql.Result, error) {
	if r.tx != nil {
		return r.tx.ExecContext(ctx, query, args...)
	}
	return r.db.ExecContext(ctx, query, args...)
}

// ─── Quota ────────────────────────────────────────────────────────────────────

func (r *aiRepository) GetQuota(ctx context.Context, tenantID uuid.UUID) (*domain.AITenantQuota, error) {
	query := `SELECT tenant_id, total_input_tokens, input_tokens_used, total_output_tokens, output_tokens_used, updated_at 
			  FROM ai_tenant_quotas WHERE tenant_id = $1`
	var quota domain.AITenantQuota
	err := r.queryRow(ctx, query, tenantID).Scan(
		&quota.TenantID, &quota.TotalInputTokens, &quota.InputTokensUsed,
		&quota.TotalOutputTokens, &quota.OutputTokensUsed, &quota.UpdatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return &quota, err
}

func (r *aiRepository) AddTokensUsed(ctx context.Context, tenantID uuid.UUID, inputUsed, outputUsed int64) error {
	query := `UPDATE ai_tenant_quotas 
			  SET input_tokens_used = input_tokens_used + $1, 
			      output_tokens_used = output_tokens_used + $2,
			      updated_at = CURRENT_TIMESTAMP 
			  WHERE tenant_id = $3`
	_, err := r.exec(ctx, query, inputUsed, outputUsed, tenantID)
	return err
}

func (r *aiRepository) TopupQuota(ctx context.Context, tenantID uuid.UUID, addInputTokens, addOutputTokens int64) error {
	query := `UPDATE ai_tenant_quotas 
			  SET total_input_tokens = total_input_tokens + $1, 
			      total_output_tokens = total_output_tokens + $2,
			      updated_at = CURRENT_TIMESTAMP 
			  WHERE tenant_id = $3`
	_, err := r.exec(ctx, query, addInputTokens, addOutputTokens, tenantID)
	return err
}

// ─── Module Settings ──────────────────────────────────────────────────────────

func scanModuleSetting(row *sql.Row) (*domain.AIModuleSetting, error) {
	var s domain.AIModuleSetting
	var id, updatedAt string
	err := row.Scan(
		&id, &s.TenantID, &s.ModuleName, &s.IsActive,
		&s.MonthlyLimit, &s.DailyLimit, &s.MonthlyUsed, &s.DailyUsed,
		&s.LastResetDate, &updatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	parsed, _ := uuid.Parse(id)
	s.ID = parsed
	s.UpdatedAt = updatedAt
	return &s, nil
}

func (r *aiRepository) GetModuleSetting(ctx context.Context, tenantID uuid.UUID, moduleName string) (*domain.AIModuleSetting, error) {
	query := `SELECT id, tenant_id, module_name, is_active, 
			  COALESCE(monthly_limit, 0), COALESCE(daily_limit, 0), COALESCE(monthly_used, 0), COALESCE(daily_used, 0),
			  last_reset_date, COALESCE(updated_at, '') 
			  FROM ai_module_settings WHERE tenant_id = $1 AND module_name = $2`
	return scanModuleSetting(r.queryRow(ctx, query, tenantID, moduleName))
}

func (r *aiRepository) GetAllModuleSettings(ctx context.Context, tenantID uuid.UUID) ([]*domain.AIModuleSetting, error) {
	query := `SELECT id, tenant_id, module_name, is_active, 
			  COALESCE(monthly_limit, 0), COALESCE(daily_limit, 0), COALESCE(monthly_used, 0), COALESCE(daily_used, 0),
			  last_reset_date, COALESCE(updated_at, '')
			  FROM ai_module_settings WHERE tenant_id = $1 ORDER BY module_name ASC`
	rows, err := r.query(ctx, query, tenantID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var settings []*domain.AIModuleSetting
	for rows.Next() {
		var s domain.AIModuleSetting
		var id, updatedAt string
		if err := rows.Scan(
			&id, &s.TenantID, &s.ModuleName, &s.IsActive,
			&s.MonthlyLimit, &s.DailyLimit, &s.MonthlyUsed, &s.DailyUsed,
			&s.LastResetDate, &updatedAt,
		); err != nil {
			return nil, err
		}
		parsed, _ := uuid.Parse(id)
		s.ID = parsed
		s.UpdatedAt = updatedAt
		settings = append(settings, &s)
	}
	return settings, nil
}

func (r *aiRepository) SetModuleSetting(ctx context.Context, setting *domain.AIModuleSetting) error {
	if setting.ID == uuid.Nil {
		setting.ID = uuid.New()
	}
	query := `
		INSERT INTO ai_module_settings (id, tenant_id, module_name, is_active, monthly_limit, daily_limit, monthly_used, daily_used, last_reset_date, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, CURRENT_TIMESTAMP)
		ON CONFLICT(tenant_id, module_name) DO UPDATE 
		SET is_active = EXCLUDED.is_active,
		    monthly_limit = EXCLUDED.monthly_limit,
		    daily_limit = EXCLUDED.daily_limit,
		    updated_at = CURRENT_TIMESTAMP
	`
	today := time.Now().Truncate(24 * time.Hour)
	_, err := r.exec(ctx, query,
		setting.ID, setting.TenantID, setting.ModuleName, setting.IsActive,
		setting.MonthlyLimit, setting.DailyLimit, setting.MonthlyUsed, setting.DailyUsed,
		today,
	)
	return err
}

func (r *aiRepository) IncrementModuleUsage(ctx context.Context, tenantID uuid.UUID, moduleName string) error {
	today := time.Now().Truncate(24 * time.Hour)
	// If last_reset_date != today, reset daily_used first
	query := `
		UPDATE ai_module_settings
		SET 
			daily_used = CASE WHEN last_reset_date < $3 THEN 1 ELSE daily_used + 1 END,
			monthly_used = CASE 
				WHEN last_reset_date IS NULL OR DATE_PART('month', last_reset_date) != DATE_PART('month', $3::date) 
				THEN 1 
				ELSE monthly_used + 1 
			END,
			last_reset_date = CASE WHEN last_reset_date < $3 THEN $3 ELSE last_reset_date END,
			updated_at = CURRENT_TIMESTAMP
		WHERE tenant_id = $1 AND module_name = $2
	`
	_, err := r.exec(ctx, query, tenantID, moduleName, today)
	return err
}

// ─── Permission Check ─────────────────────────────────────────────────────────

func (r *aiRepository) HasPermission(ctx context.Context, userID uuid.UUID, permissionName string) (bool, error) {
	// Admins (category = 'Admin') always have all permissions
	var category string
	catQuery := `SELECT category FROM users WHERE id = $1`
	if err := r.queryRow(ctx, catQuery, userID).Scan(&category); err != nil {
		if err == sql.ErrNoRows {
			return false, nil
		}
		return false, err
	}
	if category == "Admin" {
		return true, nil
	}

	// For non-Admins: check role_permissions → permissions table
	query := `
		SELECT COUNT(p.id) FROM permissions p
		JOIN role_permissions rp ON rp.permission_id = p.id
		JOIN user_roles ur ON ur.role_id = rp.role_id
		WHERE ur.user_id = $1 AND p.name = $2
	`
	var count int
	err := r.queryRow(ctx, query, userID, permissionName).Scan(&count)
	if err != nil {
		return false, err
	}
	return count > 0, nil
}
