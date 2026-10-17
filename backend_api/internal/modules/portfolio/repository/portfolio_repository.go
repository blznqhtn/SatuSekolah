package repository

import (
	"context"
	"database/sql"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/portfolio/domain"
)

type portfolioRepository struct {
	db *sql.DB
	tx *sql.Tx
}

func NewPortfolioRepository(db *sql.DB) domain.PortfolioRepository {
	return &portfolioRepository{db: db}
}

func (r *portfolioRepository) queryRow(ctx context.Context, query string, args ...interface{}) *sql.Row {
	if r.tx != nil {
		return r.tx.QueryRowContext(ctx, query, args...)
	}
	return r.db.QueryRowContext(ctx, query, args...)
}

func (r *portfolioRepository) query(ctx context.Context, query string, args ...interface{}) (*sql.Rows, error) {
	if r.tx != nil {
		return r.tx.QueryContext(ctx, query, args...)
	}
	return r.db.QueryContext(ctx, query, args...)
}

func (r *portfolioRepository) exec(ctx context.Context, query string, args ...interface{}) (sql.Result, error) {
	if r.tx != nil {
		return r.tx.ExecContext(ctx, query, args...)
	}
	return r.db.ExecContext(ctx, query, args...)
}

func (r *portfolioRepository) GetPortfolioByUserID(ctx context.Context, userID uuid.UUID) (*domain.Portfolio, error) {
	var p domain.Portfolio
	err := r.queryRow(ctx,
		`SELECT id, user_id, summary, cv_url, created_at, updated_at FROM portfolios WHERE user_id = $1 AND deleted_at IS NULL LIMIT 1`,
		userID,
	).Scan(&p.ID, &p.UserID, &p.Summary, &p.CVUrl, &p.CreatedAt, &p.UpdatedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}

	// Load sub-items
	p.Experiences, _ = r.getExperiences(ctx, p.ID)
	p.Educations, _ = r.getEducations(ctx, p.ID)
	p.Projects, _ = r.getProjects(ctx, p.ID)
	p.Skills, _ = r.getSkills(ctx, p.ID)
	p.Certificates, _ = r.getCertificates(ctx, p.ID)

	return &p, nil
}

func (r *portfolioRepository) UpsertPortfolioSummary(ctx context.Context, userID uuid.UUID, summary, cvUrl string) (*domain.Portfolio, error) {
	// Try update first
	res, err := r.exec(ctx,
		`UPDATE portfolios SET summary = COALESCE(NULLIF($1,''), summary), cv_url = COALESCE(NULLIF($2,''), cv_url), updated_at = NOW() WHERE user_id = $3 AND deleted_at IS NULL`,
		summary, cvUrl, userID,
	)
	if err != nil {
		return nil, err
	}
	rows, _ := res.RowsAffected()
	if rows == 0 {
		// Create new
		id := uuid.New()
		_, err = r.exec(ctx,
			`INSERT INTO portfolios (id, user_id, summary, cv_url) VALUES ($1, $2, $3, $4)`,
			id, userID, summary, cvUrl,
		)
		if err != nil {
			return nil, err
		}
	}
	return r.GetPortfolioByUserID(ctx, userID)
}

func (r *portfolioRepository) getExperiences(ctx context.Context, portID uuid.UUID) ([]domain.PortfolioExperience, error) {
	rows, err := r.query(ctx,
		`SELECT id, portfolio_id, title, company_name, start_date, end_date, is_current, description FROM portfolio_experiences WHERE portfolio_id = $1`,
		portID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var exps []domain.PortfolioExperience
	for rows.Next() {
		var e domain.PortfolioExperience
		if err := rows.Scan(&e.ID, &e.PortfolioID, &e.Title, &e.CompanyName, &e.StartDate, &e.EndDate, &e.IsCurrent, &e.Description); err != nil {
			continue
		}
		exps = append(exps, e)
	}
	return exps, nil
}

func (r *portfolioRepository) getEducations(ctx context.Context, portID uuid.UUID) ([]domain.PortfolioEducation, error) {
	rows, err := r.query(ctx,
		`SELECT id, portfolio_id, school, degree, field_of_study, start_date, end_date FROM portfolio_educations WHERE portfolio_id = $1`,
		portID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var edus []domain.PortfolioEducation
	for rows.Next() {
		var e domain.PortfolioEducation
		if err := rows.Scan(&e.ID, &e.PortfolioID, &e.School, &e.Degree, &e.FieldOfStudy, &e.StartDate, &e.EndDate); err != nil {
			continue
		}
		edus = append(edus, e)
	}
	return edus, nil
}

func (r *portfolioRepository) getProjects(ctx context.Context, portID uuid.UUID) ([]domain.PortfolioProject, error) {
	rows, err := r.query(ctx,
		`SELECT id, portfolio_id, title, description, project_url, thumbnail_url FROM portfolio_projects WHERE portfolio_id = $1`,
		portID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var projs []domain.PortfolioProject
	for rows.Next() {
		var p domain.PortfolioProject
		if err := rows.Scan(&p.ID, &p.PortfolioID, &p.Title, &p.Description, &p.ProjectUrl, &p.ThumbnailUrl); err != nil {
			continue
		}
		projs = append(projs, p)
	}
	return projs, nil
}

func (r *portfolioRepository) getSkills(ctx context.Context, portID uuid.UUID) ([]domain.PortfolioSkill, error) {
	rows, err := r.query(ctx,
		`SELECT id, portfolio_id, skill_name FROM portfolio_skills WHERE portfolio_id = $1`,
		portID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var skills []domain.PortfolioSkill
	for rows.Next() {
		var s domain.PortfolioSkill
		if err := rows.Scan(&s.ID, &s.PortfolioID, &s.SkillName); err != nil {
			continue
		}
		skills = append(skills, s)
	}
	return skills, nil
}

func (r *portfolioRepository) getCertificates(ctx context.Context, portID uuid.UUID) ([]domain.PortfolioCertificate, error) {
	rows, err := r.query(ctx,
		`SELECT id, portfolio_id, name, issuing_organization, issue_date, credential_url FROM portfolio_certificates WHERE portfolio_id = $1`,
		portID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var certs []domain.PortfolioCertificate
	for rows.Next() {
		var c domain.PortfolioCertificate
		if err := rows.Scan(&c.ID, &c.PortfolioID, &c.Name, &c.IssuingOrganization, &c.IssueDate, &c.CredentialUrl); err != nil {
			continue
		}
		certs = append(certs, c)
	}
	return certs, nil
}

func (r *portfolioRepository) AddExperience(ctx context.Context, exp *domain.PortfolioExperience) error {
	_, err := r.exec(ctx,
		`INSERT INTO portfolio_experiences (id, portfolio_id, title, company_name, start_date, end_date, is_current, description) VALUES ($1,$2,$3,$4,$5,$6,$7,$8)`,
		exp.ID, exp.PortfolioID, exp.Title, exp.CompanyName, exp.StartDate, exp.EndDate, exp.IsCurrent, exp.Description,
	)
	return err
}

func (r *portfolioRepository) DeleteExperience(ctx context.Context, id uuid.UUID) error {
	_, err := r.exec(ctx, `DELETE FROM portfolio_experiences WHERE id = $1`, id)
	return err
}

func (r *portfolioRepository) AddEducation(ctx context.Context, edu *domain.PortfolioEducation) error {
	_, err := r.exec(ctx,
		`INSERT INTO portfolio_educations (id, portfolio_id, school, degree, field_of_study, start_date, end_date) VALUES ($1,$2,$3,$4,$5,$6,$7)`,
		edu.ID, edu.PortfolioID, edu.School, edu.Degree, edu.FieldOfStudy, edu.StartDate, edu.EndDate,
	)
	return err
}

func (r *portfolioRepository) DeleteEducation(ctx context.Context, id uuid.UUID) error {
	_, err := r.exec(ctx, `DELETE FROM portfolio_educations WHERE id = $1`, id)
	return err
}

func (r *portfolioRepository) AddProject(ctx context.Context, proj *domain.PortfolioProject) error {
	_, err := r.exec(ctx,
		`INSERT INTO portfolio_projects (id, portfolio_id, title, description, project_url, thumbnail_url) VALUES ($1,$2,$3,$4,$5,$6)`,
		proj.ID, proj.PortfolioID, proj.Title, proj.Description, proj.ProjectUrl, proj.ThumbnailUrl,
	)
	return err
}

func (r *portfolioRepository) DeleteProject(ctx context.Context, id uuid.UUID) error {
	_, err := r.exec(ctx, `DELETE FROM portfolio_projects WHERE id = $1`, id)
	return err
}

func (r *portfolioRepository) AddSkill(ctx context.Context, skill *domain.PortfolioSkill) error {
	_, err := r.exec(ctx,
		`INSERT INTO portfolio_skills (id, portfolio_id, skill_name) VALUES ($1,$2,$3)`,
		skill.ID, skill.PortfolioID, skill.SkillName,
	)
	return err
}

func (r *portfolioRepository) DeleteSkill(ctx context.Context, id uuid.UUID) error {
	_, err := r.exec(ctx, `DELETE FROM portfolio_skills WHERE id = $1`, id)
	return err
}

func (r *portfolioRepository) AddCertificate(ctx context.Context, cert *domain.PortfolioCertificate) error {
	_, err := r.exec(ctx,
		`INSERT INTO portfolio_certificates (id, portfolio_id, name, issuing_organization, issue_date, credential_url) VALUES ($1,$2,$3,$4,$5,$6)`,
		cert.ID, cert.PortfolioID, cert.Name, cert.IssuingOrganization, cert.IssueDate, cert.CredentialUrl,
	)
	return err
}

func (r *portfolioRepository) DeleteCertificate(ctx context.Context, id uuid.UUID) error {
	_, err := r.exec(ctx, `DELETE FROM portfolio_certificates WHERE id = $1`, id)
	return err
}

func (r *portfolioRepository) BatchInsertExperiences(ctx context.Context, exps []domain.PortfolioExperience) error {
	for _, e := range exps {
		if err := r.AddExperience(ctx, &e); err != nil {
			return err
		}
	}
	return nil
}

func (r *portfolioRepository) BatchInsertEducations(ctx context.Context, edus []domain.PortfolioEducation) error {
	for _, e := range edus {
		if err := r.AddEducation(ctx, &e); err != nil {
			return err
		}
	}
	return nil
}

func (r *portfolioRepository) BatchInsertSkills(ctx context.Context, skills []domain.PortfolioSkill) error {
	for _, s := range skills {
		if err := r.AddSkill(ctx, &s); err != nil {
			return err
		}
	}
	return nil
}
