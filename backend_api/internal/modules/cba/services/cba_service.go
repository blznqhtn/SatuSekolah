package services

import (
	"context"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/cba/entities"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/cba/requests"
)

type CbaService interface {
	CreateCompany(ctx context.Context, req *requests.CreateCompanyRequest) (*entities.Company, error)
	CreateJobVacancy(ctx context.Context, req *requests.CreateJobVacancyRequest) (*entities.JobVacancy, error)
	ApplyJob(ctx context.Context, req *requests.ApplyJobRequest) (*entities.JobApplication, error)
}
