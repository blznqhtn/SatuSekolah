package repository

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/violations/domain"
)

type violationRepository struct {
	db *sql.DB
}

func NewViolationRepository(db *sql.DB) domain.ViolationRepository {
	return &violationRepository{db: db}
}

func (r *violationRepository) CreateViolationType(ctx context.Context, vt *domain.ViolationType) error {
	q := `INSERT INTO violation_types (id, tenant_id, name, description, points, applies_to, is_active, is_system_default, created_by)
		  VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`
	_, err := r.db.ExecContext(ctx, q,
		vt.ID, vt.TenantID, vt.Name, vt.Description, vt.Points,
		vt.AppliesTo, vt.IsActive, vt.IsSystemDefault, vt.CreatedBy)
	return err
}

func (r *violationRepository) GetViolationTypes(ctx context.Context, tenantID uuid.UUID) ([]*domain.ViolationType, error) {
	// Returns both global system defaults (tenant_id IS NULL) and tenant-specific ones
	q := `SELECT id, tenant_id, name, description, points, applies_to, is_active, is_system_default, created_by, created_at
		  FROM violation_types WHERE (tenant_id = ? OR tenant_id IS NULL) ORDER BY is_system_default DESC, created_at ASC`
	rows, err := r.db.QueryContext(ctx, q, tenantID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []*domain.ViolationType
	for rows.Next() {
		var vt domain.ViolationType
		if err := rows.Scan(&vt.ID, &vt.TenantID, &vt.Name, &vt.Description, &vt.Points,
			&vt.AppliesTo, &vt.IsActive, &vt.IsSystemDefault, &vt.CreatedBy, &vt.CreatedAt); err != nil {
			return nil, err
		}
		results = append(results, &vt)
	}
	return results, nil
}

func (r *violationRepository) GetViolationTypeByID(ctx context.Context, id string) (*domain.ViolationType, error) {
	q := `SELECT id, tenant_id, name, description, points, applies_to, is_active, is_system_default, created_by, created_at
		  FROM violation_types WHERE id = ?`
	var vt domain.ViolationType
	err := r.db.QueryRowContext(ctx, q, id).Scan(&vt.ID, &vt.TenantID, &vt.Name, &vt.Description, &vt.Points,
		&vt.AppliesTo, &vt.IsActive, &vt.IsSystemDefault, &vt.CreatedBy, &vt.CreatedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return &vt, err
}

func (r *violationRepository) ToggleViolationTypeActive(ctx context.Context, id string, isActive bool) error {
	_, err := r.db.ExecContext(ctx, `UPDATE violation_types SET is_active = ? WHERE id = ?`, isActive, id)
	return err
}

func (r *violationRepository) DeleteViolationType(ctx context.Context, id string) error {
	_, err := r.db.ExecContext(ctx, `DELETE FROM violation_types WHERE id = ? AND is_system_default = FALSE`, id)
	return err
}

func (r *violationRepository) CreateUserViolation(ctx context.Context, uv *domain.UserViolation) error {
	q := `INSERT INTO user_violations (id, tenant_id, user_id, violation_type_id, points_applied, evidence_url, notes, recorded_by, parent_notified)
		  VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`
	uv.ID = uuid.New()
	uv.CreatedAt = time.Now()
	_, err := r.db.ExecContext(ctx, q,
		uv.ID, uv.TenantID, uv.UserID, uv.ViolationTypeID,
		uv.PointsApplied, uv.EvidenceURL, uv.Notes, uv.RecordedBy, uv.ParentNotified)
	return err
}

func (r *violationRepository) GetUserViolations(ctx context.Context, tenantID, userID uuid.UUID) ([]*domain.UserViolation, error) {
	q := `SELECT uv.id, uv.tenant_id, uv.user_id, uv.violation_type_id, uv.points_applied, 
		         uv.evidence_url, uv.notes, uv.recorded_by, uv.parent_notified, uv.created_at
		  FROM user_violations uv WHERE uv.tenant_id = ? AND uv.user_id = ? ORDER BY uv.created_at DESC`
	rows, err := r.db.QueryContext(ctx, q, tenantID, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []*domain.UserViolation
	for rows.Next() {
		var uv domain.UserViolation
		if err := rows.Scan(&uv.ID, &uv.TenantID, &uv.UserID, &uv.ViolationTypeID, &uv.PointsApplied,
			&uv.EvidenceURL, &uv.Notes, &uv.RecordedBy, &uv.ParentNotified, &uv.CreatedAt); err != nil {
			return nil, err
		}
		results = append(results, &uv)
	}
	return results, nil
}

func (r *violationRepository) GetUserTotalPoints(ctx context.Context, tenantID, userID uuid.UUID) (int, error) {
	q := `SELECT COALESCE(SUM(points_applied), 0) FROM user_violations WHERE tenant_id = ? AND user_id = ?`
	var total int
	err := r.db.QueryRowContext(ctx, q, tenantID, userID).Scan(&total)
	return total, err
}

func (r *violationRepository) RecordSystemLateViolation(ctx context.Context, tenantID, userID uuid.UUID, category domain.AppliesToCategory) error {
	// Get the system violation type for this category
	typeID := domain.SystemViolationLateStudent
	if category == domain.AppliesToStaff {
		typeID = domain.SystemViolationLateStaff
	}

	vt, err := r.GetViolationTypeByID(ctx, typeID)
	if err != nil || vt == nil || !vt.IsActive {
		return nil // Silently skip if type doesn't exist or is inactive
	}

	uv := &domain.UserViolation{
		ID:              uuid.New(),
		TenantID:        tenantID,
		UserID:          userID,
		ViolationTypeID: typeID,
		PointsApplied:   vt.Points,
		RecordedBy:      nil, // system-triggered
		ParentNotified:  false,
	}
	return r.CreateUserViolation(ctx, uv)
}

func (r *violationRepository) GetParentIDByUserID(ctx context.Context, userID uuid.UUID) (*uuid.UUID, error) {
	q := `SELECT parent_id FROM users WHERE id = ? AND parent_id IS NOT NULL`
	var parentID uuid.UUID
	err := r.db.QueryRowContext(ctx, q, userID).Scan(&parentID)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("failed to get parent_id: %w", err)
	}
	return &parentID, nil
}
