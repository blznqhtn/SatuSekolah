package services

import (
	"context"

	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/core/entities"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/core/requests"
)

type TenantService interface {
	CreateTenant(ctx context.Context, req *requests.CreateTenantRequest) (*entities.Tenant, error)
	GetTenantByID(ctx context.Context, id string) (*entities.Tenant, error)
	// Add other service methods here
}
