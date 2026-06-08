package domain

import (
	"context"
	"time"

	"github.com/google/uuid"
)

type Portfolio struct {
	ID        uuid.UUID               `json:"id"`
	UserID    uuid.UUID               `json:"user_id"`
	Summary   string                  `json:"summary"`
	CVUrl     string                  `json:"cv_url"`
	CreatedAt time.Time               `json:"created_at"`
	UpdatedAt time.Time               `json:"updated_at"`
	
	// Relations
	Experiences  []PortfolioExperience  `json:"experiences"`
	Educations   []PortfolioEducation   `json:"educations"`
	Projects     []PortfolioProject     `json:"projects"`
	Skills       []PortfolioSkill       `json:"skills"`
	Certificates []PortfolioCertificate `json:"certificates"`
}

type PortfolioExperience struct {
	ID          uuid.UUID  `json:"id"`
	PortfolioID uuid.UUID  `json:"portfolio_id"`
	Title       string     `json:"title"`
	CompanyName string     `json:"company_name"`
	StartDate   *time.Time `json:"start_date"`
	EndDate     *time.Time `json:"end_date"`
	IsCurrent   bool       `json:"is_current"`
	Description string     `json:"description"`
}

type PortfolioEducation struct {
	ID           uuid.UUID  `json:"id"`
	PortfolioID  uuid.UUID  `json:"portfolio_id"`
	School       string     `json:"school"`
	Degree       string     `json:"degree"`
	FieldOfStudy string     `json:"field_of_study"`
	StartDate    *time.Time `json:"start_date"`
	EndDate      *time.Time `json:"end_date"`
}

type PortfolioProject struct {
	ID           uuid.UUID `json:"id"`
	PortfolioID  uuid.UUID `json:"portfolio_id"`
	Title        string    `json:"title"`
	Description  string    `json:"description"`
	ProjectUrl   string    `json:"project_url"`
	ThumbnailUrl string    `json:"thumbnail_url"`
}

type PortfolioSkill struct {
	ID          uuid.UUID `json:"id"`
	PortfolioID uuid.UUID `json:"portfolio_id"`
	SkillName   string    `json:"skill_name"`
}

type PortfolioCertificate struct {
	ID                  uuid.UUID  `json:"id"`
	PortfolioID         uuid.UUID  `json:"portfolio_id"`
	Name                string     `json:"name"`
	IssuingOrganization string     `json:"issuing_organization"`
	IssueDate           *time.Time `json:"issue_date"`
	CredentialUrl       string     `json:"credential_url"`
}

// Interfaces

type PortfolioRepository interface {
	GetPortfolioByUserID(ctx context.Context, userID uuid.UUID) (*Portfolio, error)
	UpsertPortfolioSummary(ctx context.Context, userID uuid.UUID, summary, cvUrl string) (*Portfolio, error)
	
	// Items Management
	AddExperience(ctx context.Context, exp *PortfolioExperience) error
	DeleteExperience(ctx context.Context, id uuid.UUID) error
	
	AddEducation(ctx context.Context, edu *PortfolioEducation) error
	DeleteEducation(ctx context.Context, id uuid.UUID) error
	
	AddProject(ctx context.Context, proj *PortfolioProject) error
	DeleteProject(ctx context.Context, id uuid.UUID) error
	
	AddSkill(ctx context.Context, skill *PortfolioSkill) error
	DeleteSkill(ctx context.Context, id uuid.UUID) error
	
	AddCertificate(ctx context.Context, cert *PortfolioCertificate) error
	DeleteCertificate(ctx context.Context, id uuid.UUID) error

	// Batch Insert (for AI extraction)
	BatchInsertExperiences(ctx context.Context, exps []PortfolioExperience) error
	BatchInsertEducations(ctx context.Context, edus []PortfolioEducation) error
	BatchInsertSkills(ctx context.Context, skills []PortfolioSkill) error
}

type PortfolioUsecase interface {
	GetMyPortfolio(ctx context.Context, userID uuid.UUID) (*Portfolio, error)
	UpdateSummary(ctx context.Context, userID uuid.UUID, summary, cvUrl string) (*Portfolio, error)
	
	AddExperience(ctx context.Context, userID uuid.UUID, exp *PortfolioExperience) error
	DeleteExperience(ctx context.Context, userID uuid.UUID, expID uuid.UUID) error
	
	AddEducation(ctx context.Context, userID uuid.UUID, edu *PortfolioEducation) error
	DeleteEducation(ctx context.Context, userID uuid.UUID, eduID uuid.UUID) error
	
	AddProject(ctx context.Context, userID uuid.UUID, proj *PortfolioProject) error
	DeleteProject(ctx context.Context, userID uuid.UUID, projID uuid.UUID) error
	
	AddSkill(ctx context.Context, userID uuid.UUID, skillName string) error
	DeleteSkill(ctx context.Context, userID uuid.UUID, skillID uuid.UUID) error
	
	AddCertificate(ctx context.Context, userID uuid.UUID, cert *PortfolioCertificate) error
	DeleteCertificate(ctx context.Context, userID uuid.UUID, certID uuid.UUID) error

	// AI Parsing
	ExtractPortfolioFromLinkedInPDF(ctx context.Context, userID uuid.UUID, pdfPath string) error
}
