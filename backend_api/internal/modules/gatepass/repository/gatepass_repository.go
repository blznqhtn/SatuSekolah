package repository

import (
	"context"
	"database/sql"
	"time"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/gatepass/domain"
)

type gatePassRepository struct {
	db *sql.DB
	tx *sql.Tx
}

func NewGatePassRepository(db *sql.DB) domain.GatePassRepository {
	return &gatePassRepository{db: db}
}

func (r *gatePassRepository) ExecTx(ctx context.Context, fn func(repo domain.GatePassRepository) error) error {
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	txRepo := &gatePassRepository{db: r.db, tx: tx}
	if err := fn(txRepo); err != nil {
		_ = tx.Rollback()
		return err
	}
	return tx.Commit()
}

func (r *gatePassRepository) queryRow(ctx context.Context, query string, args ...interface{}) *sql.Row {
	if r.tx != nil {
		return r.tx.QueryRowContext(ctx, query, args...)
	}
	return r.db.QueryRowContext(ctx, query, args...)
}

func (r *gatePassRepository) exec(ctx context.Context, query string, args ...interface{}) (sql.Result, error) {
	if r.tx != nil {
		return r.tx.ExecContext(ctx, query, args...)
	}
	return r.db.ExecContext(ctx, query, args...)
}

func (r *gatePassRepository) UpsertSetting(ctx context.Context, setting *GatePassSetting) error {
	if setting.ID == uuid.Nil {
		setting.ID = uuid.New()
	}
	query := `
		INSERT INTO gate_pass_settings (id, tenant_id, level_1_role_id, level_2_role_id, level_3_role_id, main_approver_role_id)
		VALUES ($1, $2, $3, $4, $5, $6)
		ON CONFLICT (tenant_id) DO UPDATE 
		SET level_1_role_id = EXCLUDED.level_1_role_id,
		    level_2_role_id = EXCLUDED.level_2_role_id,
		    level_3_role_id = EXCLUDED.level_3_role_id,
		    main_approver_role_id = EXCLUDED.main_approver_role_id,
		    updated_at = CURRENT_TIMESTAMP
	`
	_, err := r.exec(ctx, query, setting.ID, setting.TenantID, setting.Level1RoleID, setting.Level2RoleID, setting.Level3RoleID, setting.MainApproverRoleID)
	return err
}

type GatePassSetting = domain.GatePassSetting

func (r *gatePassRepository) GetSetting(ctx context.Context, tenantID uuid.UUID) (*domain.GatePassSetting, error) {
	query := `SELECT id, tenant_id, level_1_role_id, level_2_role_id, level_3_role_id, main_approver_role_id, updated_at FROM gate_pass_settings WHERE tenant_id = $1`
	var s domain.GatePassSetting
	err := r.queryRow(ctx, query, tenantID).Scan(&s.ID, &s.TenantID, &s.Level1RoleID, &s.Level2RoleID, &s.Level3RoleID, &s.MainApproverRoleID, &s.UpdatedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return &s, err
}

func (r *gatePassRepository) CreateGatePass(ctx context.Context, pass *domain.GatePass) error {
	if pass.ID == uuid.Nil {
		pass.ID = uuid.New()
	}
	query := `
		INSERT INTO gate_passes (id, tenant_id, student_id, reason, expected_exit_time, expected_return_time, status)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
	`
	_, err := r.exec(ctx, query, pass.ID, pass.TenantID, pass.StudentID, pass.Reason, pass.ExpectedExitTime, pass.ExpectedReturnTime, pass.Status)
	return err
}

func (r *gatePassRepository) GetGatePassByID(ctx context.Context, id uuid.UUID) (*domain.GatePass, error) {
	query := `SELECT id, tenant_id, student_id, reason, expected_exit_time, expected_return_time, actual_exit_time, actual_return_time, exit_qr_token, return_qr_token, status, created_at, updated_at FROM gate_passes WHERE id = $1`
	var p domain.GatePass
	err := r.queryRow(ctx, query, id).Scan(&p.ID, &p.TenantID, &p.StudentID, &p.Reason, &p.ExpectedExitTime, &p.ExpectedReturnTime, &p.ActualExitTime, &p.ActualReturnTime, &p.ExitQRToken, &p.ReturnQRToken, &p.Status, &p.CreatedAt, &p.UpdatedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return &p, err
}

func (r *gatePassRepository) GetGatePassByExitQR(ctx context.Context, exitQR string) (*domain.GatePass, error) {
	query := `SELECT id, tenant_id, student_id, reason, expected_exit_time, expected_return_time, actual_exit_time, actual_return_time, exit_qr_token, return_qr_token, status, created_at, updated_at FROM gate_passes WHERE exit_qr_token = $1`
	var p domain.GatePass
	err := r.queryRow(ctx, query, exitQR).Scan(&p.ID, &p.TenantID, &p.StudentID, &p.Reason, &p.ExpectedExitTime, &p.ExpectedReturnTime, &p.ActualExitTime, &p.ActualReturnTime, &p.ExitQRToken, &p.ReturnQRToken, &p.Status, &p.CreatedAt, &p.UpdatedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return &p, err
}

func (r *gatePassRepository) GetGatePassByReturnQR(ctx context.Context, returnQR string) (*domain.GatePass, error) {
	query := `SELECT id, tenant_id, student_id, reason, expected_exit_time, expected_return_time, actual_exit_time, actual_return_time, exit_qr_token, return_qr_token, status, created_at, updated_at FROM gate_passes WHERE return_qr_token = $1`
	var p domain.GatePass
	err := r.queryRow(ctx, query, returnQR).Scan(&p.ID, &p.TenantID, &p.StudentID, &p.Reason, &p.ExpectedExitTime, &p.ExpectedReturnTime, &p.ActualExitTime, &p.ActualReturnTime, &p.ExitQRToken, &p.ReturnQRToken, &p.Status, &p.CreatedAt, &p.UpdatedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return &p, err
}

func (r *gatePassRepository) UpdateGatePass(ctx context.Context, pass *domain.GatePass) error {
	now := time.Now()
	pass.UpdatedAt = now
	query := `UPDATE gate_passes SET status = $1, exit_qr_token = $2, return_qr_token = $3, actual_exit_time = $4, actual_return_time = $5, updated_at = $6 WHERE id = $7`
	_, err := r.exec(ctx, query, pass.Status, pass.ExitQRToken, pass.ReturnQRToken, pass.ActualExitTime, pass.ActualReturnTime, pass.UpdatedAt, pass.ID)
	return err
}

func (r *gatePassRepository) GetPendingOverdue(ctx context.Context) ([]*domain.GatePass, error) {
	query := `SELECT id, tenant_id, student_id, reason, expected_exit_time, expected_return_time, actual_exit_time, actual_return_time, exit_qr_token, return_qr_token, status, created_at, updated_at FROM gate_passes WHERE status = 'EXITED' AND expected_return_time < CURRENT_TIMESTAMP`
	rows, err := r.db.QueryContext(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var passes []*domain.GatePass
	for rows.Next() {
		var p domain.GatePass
		if err := rows.Scan(&p.ID, &p.TenantID, &p.StudentID, &p.Reason, &p.ExpectedExitTime, &p.ExpectedReturnTime, &p.ActualExitTime, &p.ActualReturnTime, &p.ExitQRToken, &p.ReturnQRToken, &p.Status, &p.CreatedAt, &p.UpdatedAt); err != nil {
			return nil, err
		}
		passes = append(passes, &p)
	}
	return passes, nil
}

func (r *gatePassRepository) CreateApprovals(ctx context.Context, approvals []*domain.GatePassApproval) error {
	for _, a := range approvals {
		if a.ID == uuid.Nil {
			a.ID = uuid.New()
		}
		query := `INSERT INTO gate_pass_approvals (id, gate_pass_id, approver_role_id, tier_level, status) VALUES ($1, $2, $3, $4, $5)`
		if _, err := r.exec(ctx, query, a.ID, a.GatePassID, a.ApproverRoleID, a.TierLevel, a.Status); err != nil {
			return err
		}
	}
	return nil
}

func (r *gatePassRepository) GetApprovals(ctx context.Context, gatePassID uuid.UUID) ([]*domain.GatePassApproval, error) {
	query := `SELECT id, gate_pass_id, approver_role_id, tier_level, status, approved_by, approved_at FROM gate_pass_approvals WHERE gate_pass_id = $1 ORDER BY tier_level ASC`
	rows, err := r.db.QueryContext(ctx, query, gatePassID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var approvals []*domain.GatePassApproval
	for rows.Next() {
		var a domain.GatePassApproval
		if err := rows.Scan(&a.ID, &a.GatePassID, &a.ApproverRoleID, &a.TierLevel, &a.Status, &a.ApprovedBy, &a.ApprovedAt); err != nil {
			return nil, err
		}
		approvals = append(approvals, &a)
	}
	return approvals, nil
}

func (r *gatePassRepository) UpdateApproval(ctx context.Context, approvalID uuid.UUID, status domain.ApprovalStatus, approvedBy uuid.UUID) error {
	now := time.Now()
	query := `UPDATE gate_pass_approvals SET status = $1, approved_by = $2, approved_at = $3 WHERE id = $4`
	_, err := r.exec(ctx, query, status, approvedBy, now, approvalID)
	return err
}
