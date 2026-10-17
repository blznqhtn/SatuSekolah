package entities

import (
	"database/sql"
	"time"

	"github.com/google/uuid"
)

type JobType string

const (
	PKL       JobType = "PKL"
	Magang    JobType = "MAGANG"
	FullTime  JobType = "FULL_TIME"
	PartTime  JobType = "PART_TIME"
	Contract  JobType = "CONTRACT"
	Freelance JobType = "FREELANCE"
)

type WorkArrangement string

const (
	OnSite WorkArrangement = "ON_SITE"
	Hybrid WorkArrangement = "HYBRID"
	Remote WorkArrangement = "REMOTE"
)

type JobAppStatus string

const (
	Applied  JobAppStatus = "APPLIED"
	Interview JobAppStatus = "INTERVIEW"
	Accepted JobAppStatus = "ACCEPTED"
	Rejected JobAppStatus = "REJECTED"
)

type Company struct {
	ID        uuid.UUID    `json:"id"`
	TenantID  uuid.UUID    `json:"tenant_id"`
	Name      string       `json:"name"`
	Industry  string       `json:"industry"`
	LogoURL   string       `json:"logo_url"`
	Address   string       `json:"address"`
	CreatedAt time.Time    `json:"created_at"`
	DeletedAt sql.NullTime `json:"deleted_at"`
}

type JobVacancy struct {
	ID           uuid.UUID       `json:"id"`
	CompanyID    uuid.UUID       `json:"company_id"`
	Title        string          `json:"title"`
	Type         JobType         `json:"type"`
	Arrangement  WorkArrangement `json:"arrangement"`
	Description  string          `json:"description"`
	Requirements string          `json:"requirements"`
	IsActive     bool            `json:"is_active"`
	CreatedAt    time.Time       `json:"created_at"`
	UpdatedAt    sql.NullTime    `json:"updated_at"`
	DeletedAt    sql.NullTime    `json:"deleted_at"`
}

type JobApplication struct {
	ID           uuid.UUID    `json:"id"`
	JobVacancyID uuid.UUID    `json:"job_vacancy_id"`
	StudentID    uuid.UUID    `json:"student_id"`
	ResumeURL    string       `json:"resume_url"`
	Status       JobAppStatus `json:"status"`
	AppliedAt    time.Time    `json:"applied_at"`
	UpdatedAt    sql.NullTime `json:"updated_at"`
}
