package usecase

import (
	"context"
	"errors"
	"time"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/career/domain"
	portfolioDomain "neuracakrawira.asia/satu-sekolah-backend/internal/modules/portfolio/domain"
)

type careerUsecase struct {
	repo          domain.CareerRepository
	portfolioRepo portfolioDomain.PortfolioRepository
}

func NewCareerUsecase(repo domain.CareerRepository, portfolioRepo portfolioDomain.PortfolioRepository) domain.CareerUsecase {
	return &careerUsecase{
		repo:          repo,
		portfolioRepo: portfolioRepo,
	}
}

func (u *careerUsecase) CreateJobVacancy(ctx context.Context, req *domain.JobVacancy) error {
	req.ID = uuid.New()
	req.CreatedAt = time.Now()
	req.IsActive = true
	return u.repo.CreateJobVacancy(ctx, req)
}

func (u *careerUsecase) GetLocalJobs(ctx context.Context, tenantID uuid.UUID) ([]*domain.JobVacancy, error) {
	return u.repo.GetLocalJobs(ctx, tenantID)
}

func (u *careerUsecase) GetPublicJobs(ctx context.Context) ([]*domain.JobVacancy, error) {
	return u.repo.GetPublicJobs(ctx)
}

func (u *careerUsecase) ApplyJob(ctx context.Context, userID, jobID uuid.UUID, resumeUrl string) error {
	job, err := u.repo.GetJobByID(ctx, jobID)
	if err != nil {
		return err
	}
	if !job.IsActive {
		return errors.New("lowongan ini sudah tidak aktif")
	}

	app := &domain.JobApplication{
		ID:           uuid.New(),
		JobVacancyID: jobID,
		UserID:       userID,
		ResumeUrl:    resumeUrl,
		Status:       domain.StatusApplied,
		AppliedAt:    time.Now(),
	}
	return u.repo.ApplyJob(ctx, app)
}

func (u *careerUsecase) GetMyApplications(ctx context.Context, userID uuid.UUID) ([]*domain.JobApplication, error) {
	return u.repo.GetMyApplications(ctx, userID)
}

func (u *careerUsecase) GetJobApplications(ctx context.Context, tenantID, jobID uuid.UUID) ([]*domain.JobApplication, error) {
	// Verifikasi apakah job ini milik tenant yang bersangkutan
	job, err := u.repo.GetJobByID(ctx, jobID)
	if err != nil {
		return nil, err
	}
	// Perusahaan/tenant pembuat yang boleh melihat
	if job.TenantID != tenantID {
		return nil, errors.New("tidak memiliki akses ke lowongan ini")
	}

	apps, err := u.repo.GetApplicationsByJob(ctx, jobID)
	if err != nil {
		return nil, err
	}

	// Attach portfolio untuk mempermudah HR melihat profile ala LinkedIn
	for _, app := range apps {
		port, _ := u.portfolioRepo.GetPortfolioByUserID(ctx, app.UserID)
		app.UserPortfolio = port
	}

	return apps, nil
}

func (u *careerUsecase) ReviewApplication(ctx context.Context, tenantID, appID uuid.UUID, status domain.JobApplicationStatus) error {
	app, err := u.repo.GetApplicationByID(ctx, appID)
	if err != nil {
		return err
	}
	job, err := u.repo.GetJobByID(ctx, app.JobVacancyID)
	if err != nil {
		return err
	}
	if job.TenantID != tenantID {
		return errors.New("tidak memiliki akses ke lamaran ini")
	}

	// Jika status ACCEPTED, maka proses integrasi role guru/staf akan dilakukan oleh Admin Core secara manual,
	// sesuai dengan arahan sistem (terpisah, pembuat akun/role adalah Admin Users).
	// BKK hanya mengubah status lamaran menjadi ACCEPTED.
	
	return u.repo.UpdateApplicationStatus(ctx, appID, status)
}
