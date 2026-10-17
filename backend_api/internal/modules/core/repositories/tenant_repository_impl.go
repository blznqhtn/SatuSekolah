package repositories

import (
	"context"
	"database/sql"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/core/entities"
)

type tenantRepository struct {
	db *sql.DB
}

func NewTenantRepository(db *sql.DB) TenantRepository {
	return &tenantRepository{db: db}
}

func (r *tenantRepository) Save(ctx context.Context, tenant *entities.Tenant) error {
	query := `INSERT INTO tenants (id, name, npsn, domain, address, phone, email, logo_url) 
              VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`
	_, err := r.db.ExecContext(ctx, query, tenant.ID, tenant.Name, tenant.NPSN, tenant.Domain, tenant.Address, tenant.Phone, tenant.Email, tenant.LogoURL)
	return err
}

func (r *tenantRepository) FindByID(ctx context.Context, id string) (*entities.Tenant, error) {
	query := `SELECT id, name, npsn, domain, address, phone, email, logo_url, created_at, updated_at, deleted_at 
              FROM tenants WHERE id = $1 AND deleted_at IS NULL`

	tenant := &entities.Tenant{}
	uid, err := uuid.Parse(id)
	if err != nil {
		return nil, err
	}

	err = r.db.QueryRowContext(ctx, query, uid).Scan(
		&tenant.ID,
		&tenant.Name,
		&tenant.NPSN,
		&tenant.Domain,
		&tenant.Address,
		&tenant.Phone,
		&tenant.Email,
		&tenant.LogoURL,
		&tenant.CreatedAt,
		&tenant.UpdatedAt,
		&tenant.DeletedAt,
	)

	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil // Or a custom not found error
		}
		return nil, err
	}

	return tenant, nil
}
