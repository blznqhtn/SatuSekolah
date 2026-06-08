package repositories

import (
	"context"

	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/core/entities"
)

type TenantRepository interface {
	Save(ctx context.Context, tenant *entities.Tenant) error
	FindByID(ctx context.Context, id string) (*entities.Tenant, error)
	// Add other repository methods here
}
