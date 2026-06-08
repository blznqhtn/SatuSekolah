package usecase

import (
	"context"

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
