package domain

import (
	"context"
	"time"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/portfolio/domain"
)

type JobVacancyType string

const (
	TypePKL       JobVacancyType = "PKL"
	TypeMagang    JobVacancyType = "MAGANG"
	TypeFullTime  JobVacancyType = "FULL_TIME"
	TypePartTime  JobVacancyType = "PART_TIME"
	TypeContract  JobVacancyType = "CONTRACT"
	TypeFreelance JobVacancyType = "FREELANCE"
)

type JobTargetRole string

const (
	TargetStudent JobTargetRole = "STUDENT"
	TargetTeacher JobTargetRole = "TEACHER"
	TargetStaff   JobTargetRole = "STAFF"
	TargetAny     JobTargetRole = "ANY"
)

type JobArrangement string

const (
	ArrOnSite JobArrangement = "ON_SITE"
	ArrHybrid JobArrangement = "HYBRID"
	ArrRemote JobArrangement = "REMOTE"
)

type JobApplicationStatus string

const (
	StatusApplied   JobApplicationStatus = "APPLIED"
	StatusReviewed  JobApplicationStatus = "REVIEWED"
	StatusInterview JobApplicationStatus = "INTERVIEW"
	StatusAccepted  JobApplicationStatus = "ACCEPTED"
	StatusRejected  JobApplicationStatus = "REJECTED"
)

type JobVacancy struct {
	ID           uuid.UUID      `json:"id"`
	CompanyID    *uuid.UUID     `json:"company_id,omitempty"` // Bisa nil jika dari sekolah langsung
	TenantID     uuid.UUID      `json:"tenant_id"`
	Title        string         `json:"title"`
	Type         JobVacancyType `json:"type"`
	TargetRole   JobTargetRole  `json:"target_role"`
	Arrangement  JobArrangement `json:"arrangement"`
	Description  string         `json:"description"`
	Requirements string         `json:"requirements"`
	IsActive     bool           `json:"is_active"`
	IsPublic     bool           `json:"is_public"`
	SalaryMin    *float64       `json:"salary_min,omitempty"`
	SalaryMax    *float64       `json:"salary_max,omitempty"`
	HideSalary   bool           `json:"hide_salary"`
	Deadline     *time.Time     `json:"deadline,omitempty"`
	CreatedAt    time.Time      `json:"created_at"`
	UpdatedAt    time.Time      `json:"updated_at"`
}

type JobApplication struct {
	ID           uuid.UUID            `json:"id"`
	JobVacancyID uuid.UUID            `json:"job_vacancy_id"`
	UserID       uuid.UUID            `json:"user_id"`
	ResumeUrl    string               `json:"resume_url"`
	Status       JobApplicationStatus `json:"status"`
	AppliedAt    time.Time            `json:"applied_at"`
	UpdatedAt    time.Time            `json:"updated_at"`
	
	// Aggregations
	UserPortfolio *domain.Portfolio `json:"portfolio,omitempty"`
}

// Interfaces

type CareerRepository interface {
	CreateJobVacancy(ctx context.Context, job *JobVacancy) error
	GetLocalJobs(ctx context.Context, tenantID uuid.UUID) ([]*JobVacancy, error)
	GetPublicJobs(ctx context.Context) ([]*JobVacancy, error)
	GetJobByID(ctx context.Context, id uuid.UUID) (*JobVacancy, error)
	
	ApplyJob(ctx context.Context, app *JobApplication) error
	GetMyApplications(ctx context.Context, userID uuid.UUID) ([]*JobApplication, error)
	GetApplicationsByJob(ctx context.Context, jobID uuid.UUID) ([]*JobApplication, error)
	
	UpdateApplicationStatus(ctx context.Context, appID uuid.UUID, status JobApplicationStatus) error
	GetApplicationByID(ctx context.Context, id uuid.UUID) (*JobApplication, error)
}

type CareerUsecase interface {
	CreateJobVacancy(ctx context.Context, req *JobVacancy) error
	GetLocalJobs(ctx context.Context, tenantID uuid.UUID) ([]*JobVacancy, error)
	GetPublicJobs(ctx context.Context) ([]*JobVacancy, error)
	
	ApplyJob(ctx context.Context, userID, jobID uuid.UUID, resumeUrl string) error
	GetMyApplications(ctx context.Context, userID uuid.UUID) ([]*JobApplication, error)
	GetJobApplications(ctx context.Context, tenantID, jobID uuid.UUID) ([]*JobApplication, error)
	
	ReviewApplication(ctx context.Context, tenantID, appID uuid.UUID, status JobApplicationStatus) error
}
