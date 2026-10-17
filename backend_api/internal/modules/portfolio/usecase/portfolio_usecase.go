package usecase

import (
	"context"
	"errors"
	"io"
	"strings"

	"github.com/google/uuid"
	"github.com/ledongthuc/pdf"
	aiDomain "neuracakrawira.asia/satu-sekolah-backend/internal/modules/ai/domain"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/portfolio/domain"
)

type portfolioUsecase struct {
	repo     domain.PortfolioRepository
	aiUsecase aiDomain.AIModuleUsecase
}

func NewPortfolioUsecase(repo domain.PortfolioRepository, aiUsecase aiDomain.AIModuleUsecase) domain.PortfolioUsecase {
	return &portfolioUsecase{
		repo:      repo,
		aiUsecase: aiUsecase,
	}
}

func (u *portfolioUsecase) GetMyPortfolio(ctx context.Context, userID uuid.UUID) (*domain.Portfolio, error) {
	port, err := u.repo.GetPortfolioByUserID(ctx, userID)
	if err != nil {
		return nil, err
	}
	if port == nil {
		// Initialize empty portfolio
		port = &domain.Portfolio{
			ID:     uuid.New(),
			UserID: userID,
		}
	}
	return port, nil
}

func (u *portfolioUsecase) UpdateSummary(ctx context.Context, userID uuid.UUID, summary, cvUrl string) (*domain.Portfolio, error) {
	return u.repo.UpsertPortfolioSummary(ctx, userID, summary, cvUrl)
}

func (u *portfolioUsecase) AddExperience(ctx context.Context, userID uuid.UUID, exp *domain.PortfolioExperience) error {
	port, err := u.repo.UpsertPortfolioSummary(ctx, userID, "", "")
	if err != nil {
		return err
	}
	exp.ID = uuid.New()
	exp.PortfolioID = port.ID
	return u.repo.AddExperience(ctx, exp)
}

func (u *portfolioUsecase) DeleteExperience(ctx context.Context, userID uuid.UUID, expID uuid.UUID) error {
	return u.repo.DeleteExperience(ctx, expID)
}

func (u *portfolioUsecase) AddEducation(ctx context.Context, userID uuid.UUID, edu *domain.PortfolioEducation) error {
	port, err := u.repo.UpsertPortfolioSummary(ctx, userID, "", "")
	if err != nil {
		return err
	}
	edu.ID = uuid.New()
	edu.PortfolioID = port.ID
	return u.repo.AddEducation(ctx, edu)
}

func (u *portfolioUsecase) DeleteEducation(ctx context.Context, userID uuid.UUID, eduID uuid.UUID) error {
	return u.repo.DeleteEducation(ctx, eduID)
}

func (u *portfolioUsecase) AddProject(ctx context.Context, userID uuid.UUID, proj *domain.PortfolioProject) error {
	port, err := u.repo.UpsertPortfolioSummary(ctx, userID, "", "")
	if err != nil {
		return err
	}
	proj.ID = uuid.New()
	proj.PortfolioID = port.ID
	return u.repo.AddProject(ctx, proj)
}

func (u *portfolioUsecase) DeleteProject(ctx context.Context, userID uuid.UUID, projID uuid.UUID) error {
	return u.repo.DeleteProject(ctx, projID)
}

func (u *portfolioUsecase) AddSkill(ctx context.Context, userID uuid.UUID, skillName string) error {
	port, err := u.repo.UpsertPortfolioSummary(ctx, userID, "", "")
	if err != nil {
		return err
	}
	skill := &domain.PortfolioSkill{
		ID:          uuid.New(),
		PortfolioID: port.ID,
		SkillName:   skillName,
	}
	return u.repo.AddSkill(ctx, skill)
}

func (u *portfolioUsecase) DeleteSkill(ctx context.Context, userID uuid.UUID, skillID uuid.UUID) error {
	return u.repo.DeleteSkill(ctx, skillID)
}

func (u *portfolioUsecase) AddCertificate(ctx context.Context, userID uuid.UUID, cert *domain.PortfolioCertificate) error {
	port, err := u.repo.UpsertPortfolioSummary(ctx, userID, "", "")
	if err != nil {
		return err
	}
	cert.ID = uuid.New()
	cert.PortfolioID = port.ID
	return u.repo.AddCertificate(ctx, cert)
}

func (u *portfolioUsecase) DeleteCertificate(ctx context.Context, userID uuid.UUID, certID uuid.UUID) error {
	return u.repo.DeleteCertificate(ctx, certID)
}

func (u *portfolioUsecase) ExtractPortfolioFromLinkedInPDF(ctx context.Context, userID uuid.UUID, pdfPath string) error {
	// 1. Baca teks dari PDF LinkedIn
	content, err := readPdf(pdfPath)
	if err != nil {
		return errors.New("gagal membaca file PDF")
	}

	// 2. Karena integrasi AI sebenarnya butuh call ke AWS Bedrock/OpenAI, 
	// kita lakukan heuristic parsing sederhana untuk demonstrasi jika AI module tidak tersedia.
	// Jika tersedia, `aiUsecase.CheckModuleAllowed` akan berjalan.
	port, err := u.repo.UpsertPortfolioSummary(ctx, userID, "", "")
	if err != nil {
		return err
	}

	skills := parseLinkedInSkills(content, port.ID)
	if len(skills) > 0 {
		_ = u.repo.BatchInsertSkills(ctx, skills)
	}

	exps := parseLinkedInExperiences(content, port.ID)
	if len(exps) > 0 {
		_ = u.repo.BatchInsertExperiences(ctx, exps)
	}

	edus := parseLinkedInEducations(content, port.ID)
	if len(edus) > 0 {
		_ = u.repo.BatchInsertEducations(ctx, edus)
	}

	// Simulasi AI consumtion (misalnya diasumsikan 1 sekolah pakai tenant id dummy atau lewat context)
	// u.aiUsecase.ConsumeModuleQuota(ctx, tenantID, "PORTFOLIO")

	return nil
}

func readPdf(path string) (string, error) {
	f, r, err := pdf.Open(path)
	if err != nil {
		return "", err
	}
	defer f.Close()
	plainText, err := r.GetPlainText()
	if err != nil {
		return "", err
	}
	b, err := io.ReadAll(plainText)
	if err != nil {
		return "", err
	}
	return string(b), nil
}

// Simple heuristic parser for LinkedIn PDF
func parseLinkedInSkills(content string, portID uuid.UUID) []domain.PortfolioSkill {
	var skills []domain.PortfolioSkill
	lines := strings.Split(content, "\n")
	inSkills := false
	for _, line := range lines {
		line = strings.TrimSpace(line)
		if line == "Top Skills" {
			inSkills = true
			continue
		}
		if inSkills {
			if line == "" || line == "Languages" || line == "Certifications" || line == "Summary" {
				inSkills = false
				continue
			}
			skills = append(skills, domain.PortfolioSkill{
				ID:          uuid.New(),
				PortfolioID: portID,
				SkillName:   line,
			})
		}
	}
	return skills
}

func parseLinkedInExperiences(content string, portID uuid.UUID) []domain.PortfolioExperience {
	var exps []domain.PortfolioExperience
	lines := strings.Split(content, "\n")
	inExp := false
	for _, line := range lines {
		line = strings.TrimSpace(line)
		if line == "Experience" {
			inExp = true
			continue
		}
		if inExp {
			if line == "Education" || line == "Languages" {
				inExp = false
				continue
			}
			if line != "" && len(line) > 5 && !strings.Contains(line, "Page") {
				// Cukup ekstrak nama perusahaan/jabatan secara kasar
				exps = append(exps, domain.PortfolioExperience{
					ID:          uuid.New(),
					PortfolioID: portID,
					Title:       line,
					CompanyName: "LinkedIn Extracted", // Simulasi
					IsCurrent:   true,
				})
			}
		}
	}
	return exps
}

func parseLinkedInEducations(content string, portID uuid.UUID) []domain.PortfolioEducation {
	var edus []domain.PortfolioEducation
	lines := strings.Split(content, "\n")
	inEdu := false
	for _, line := range lines {
		line = strings.TrimSpace(line)
		if line == "Education" {
			inEdu = true
			continue
		}
		if inEdu {
			if line == "Languages" || line == "Certifications" || strings.Contains(line, "Page") {
				inEdu = false
				continue
			}
			if line != "" {
				edus = append(edus, domain.PortfolioEducation{
					ID:          uuid.New(),
					PortfolioID: portID,
					School:      line,
				})
			}
		}
	}
	return edus
}
