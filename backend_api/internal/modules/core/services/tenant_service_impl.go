package services

import (
	"context"
	"database/sql"
	"time"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/core/entities"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/core/repositories"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/core/requests"
)

type tenantService struct {
	repo repositories.TenantRepository
}

func NewTenantService(repo repositories.TenantRepository) TenantService {
	return &tenantService{repo: repo}
}

func (s *tenantService) CreateTenant(ctx context.Context, req *requests.CreateTenantRequest) (*entities.Tenant, error) {
	tenant := &entities.Tenant{
		ID:      uuid.New(),
		Name:    req.Name,
		NPSN:    sql.NullString{String: req.NPSN, Valid: req.NPSN != ""},
		Domain:  req.Domain,
		Address: sql.NullString{String: req.Address, Valid: req.Address != ""},
		Phone:   sql.NullString{String: req.Phone, Valid: req.Phone != ""},
		Email:   sql.NullString{String: req.Email, Valid: req.Email != ""},
		LogoURL: sql.NullString{String: req.LogoURL, Valid: req.LogoURL != ""},
		CreatedAt: time.Now(),
	}

	err := s.repo.Save(ctx, tenant)
	if err != nil {
		return nil, err
	}

	return tenant, nil
}

func (s *tenantService) GetTenantByID(ctx context.Context, id string) (*entities.Tenant, error) {
	return s.repo.FindByID(ctx, id)
}
