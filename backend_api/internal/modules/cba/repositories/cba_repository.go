package repositories

import (
	"context"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/cba/entities"
)

type CompanyRepository interface {
	Save(ctx context.Context, company *entities.Company) error
}

type JobVacancyRepository interface {
	Save(ctx context.Context, jv *entities.JobVacancy) error
}

type JobApplicationRepository interface {
	Save(ctx context.Context, ja *entities.JobApplication) error
}
