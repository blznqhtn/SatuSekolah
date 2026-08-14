package usecase

import (
	"context"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/spmb/domain"
)

type spmbUsecase struct {
	repo domain.SpmbRepository
}

func NewSpmbUsecase(repo domain.SpmbRepository) domain.SpmbUsecase {
	return &spmbUsecase{repo: repo}
}

func (u *spmbUsecase) GetPublicSchools(ctx context.Context) ([]*domain.PublicSchoolInfo, error) {
	return u.repo.GetPublicSchools(ctx)
}

func (u *spmbUsecase) RegisterSpmb(ctx context.Context, reg *domain.SpmbRegistration) error {
	// Add business logic if necessary (e.g. check duplicate)
	return u.repo.CreateRegistration(ctx, reg)
}

func (u *spmbUsecase) UpdateRegistrationStatus(ctx context.Context, id uuid.UUID, status string) error {
	return u.repo.UpdateRegistrationStatus(ctx, id, status)
}

func (u *spmbUsecase) GetMyApplications(ctx context.Context, parentID uuid.UUID) ([]*domain.SpmbRegistration, error) {
	return u.repo.GetMyApplications(ctx, parentID)
}
