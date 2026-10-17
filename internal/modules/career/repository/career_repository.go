package repository

import (
	"context"
	"database/sql"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/career/domain"
)

type careerRepository struct {
	db *sql.DB
	tx *sql.Tx
}

func NewCareerRepository(db *sql.DB) domain.CareerRepository {
	return &careerRepository{db: db}
}

func (r *careerRepository) queryRow(ctx context.Context, query string, args ...interface{}) *sql.Row {
	if r.tx != nil {
		return r.tx.QueryRowContext(ctx, query, args...)
	}
	return r.db.QueryRowContext(ctx, query, args...)
}

func (r *careerRepository) query(ctx context.Context, query string, args ...interface{}) (*sql.Rows, error) {
	if r.tx != nil {
		return r.tx.QueryContext(ctx, query, args...)
	}
	return r.db.QueryContext(ctx, query, args...)
}

func (r *careerRepository) exec(ctx context.Context, query string, args ...interface{}) (sql.Result, error) {
	if r.tx != nil {
		return r.tx.ExecContext(ctx, query, args...)
	}
	return r.db.ExecContext(ctx, query, args...)
}

func scanJob(row *sql.Row) (*domain.JobVacancy, error) {
	var j domain.JobVacancy
	var idStr, tenantIDStr string
	var salaryMin, salaryMax sql.NullFloat64
	var deadline, createdAt, updatedAt sql.NullTime
	var companyID, compName, compLogo, compAddress sql.NullString
	var targetRole, arrangement, description, requirements sql.NullString
	var hideSalary sql.NullBool
	err := row.Scan(
		&idStr, &companyID, &tenantIDStr, &j.Title, &j.Type, &targetRole,
		&arrangement, &description, &requirements,
		&j.IsActive, &j.IsPublic, &salaryMin, &salaryMax,
		&hideSalary, &deadline, &createdAt, &updatedAt,
		&compName, &compLogo, &compAddress,
	)
	if err != nil {
		return nil, err
	}
	j.ID, _ = uuid.Parse(idStr)
	j.TenantID, _ = uuid.Parse(tenantIDStr)
	if companyID.Valid {
		id, _ := uuid.Parse(companyID.String)
		j.CompanyID = &id
	}
	if targetRole.Valid {
		j.TargetRole = domain.JobTargetRole(targetRole.String)
	}
	if arrangement.Valid {
		j.Arrangement = domain.JobArrangement(arrangement.String)
	}
	if description.Valid {
		j.Description = description.String
	}
	if requirements.Valid {
		j.Requirements = requirements.String
	}
	if hideSalary.Valid {
		j.HideSalary = hideSalary.Bool
	}
	if salaryMin.Valid {
		j.SalaryMin = &salaryMin.Float64
	}
	if salaryMax.Valid {
		j.SalaryMax = &salaryMax.Float64
	}
	if deadline.Valid {
		j.Deadline = &deadline.Time
	}
	if createdAt.Valid {
		j.CreatedAt = createdAt.Time
	}
	if updatedAt.Valid {
		j.UpdatedAt = updatedAt.Time
	}
	if compName.Valid {
		j.CompanyName = &compName.String
	}
	if compLogo.Valid {
		j.CompanyLogo = &compLogo.String
	}
	if compAddress.Valid {
		j.CompanyLocation = &compAddress.String
	}
	return &j, nil
}

func scanJobs(rows *sql.Rows) ([]*domain.JobVacancy, error) {
	var jobs []*domain.JobVacancy
	for rows.Next() {
		var j domain.JobVacancy
		var idStr, tenantIDStr string
		var salaryMin, salaryMax sql.NullFloat64
		var deadline, createdAt, updatedAt sql.NullTime
		var companyID, compName, compLogo, compAddress sql.NullString
		var targetRole, arrangement, description, requirements sql.NullString
		var hideSalary sql.NullBool
		if err := rows.Scan(
			&idStr, &companyID, &tenantIDStr, &j.Title, &j.Type, &targetRole,
			&arrangement, &description, &requirements,
			&j.IsActive, &j.IsPublic, &salaryMin, &salaryMax,
			&hideSalary, &deadline, &createdAt, &updatedAt,
			&compName, &compLogo, &compAddress,
		); err != nil {
			continue
		}
		j.ID, _ = uuid.Parse(idStr)
		j.TenantID, _ = uuid.Parse(tenantIDStr)
		if companyID.Valid {
			id, _ := uuid.Parse(companyID.String)
			j.CompanyID = &id
		}
		if targetRole.Valid {
			j.TargetRole = domain.JobTargetRole(targetRole.String)
		}
		if arrangement.Valid {
			j.Arrangement = domain.JobArrangement(arrangement.String)
		}
		if description.Valid {
			j.Description = description.String
		}
		if requirements.Valid {
			j.Requirements = requirements.String
		}
		if hideSalary.Valid {
			j.HideSalary = hideSalary.Bool
		}
		if salaryMin.Valid {
			j.SalaryMin = &salaryMin.Float64
		}
		if salaryMax.Valid {
			j.SalaryMax = &salaryMax.Float64
		}
		if deadline.Valid {
			j.Deadline = &deadline.Time
		}
		if createdAt.Valid {
			j.CreatedAt = createdAt.Time
		}
		if updatedAt.Valid {
			j.UpdatedAt = updatedAt.Time
		}
		if compName.Valid {
			j.CompanyName = &compName.String
		}
		if compLogo.Valid {
			j.CompanyLogo = &compLogo.String
		}
		if compAddress.Valid {
			j.CompanyLocation = &compAddress.String
		}
		jobs = append(jobs, &j)
	}
	return jobs, nil
}

const jobSelectFields = `j.id, j.company_id, j.tenant_id, j.title, j.type, j.target_role, j.arrangement, j.description, j.requirements, j.is_active, j.is_public, j.salary_min, j.salary_max, j.hide_salary, j.deadline, j.created_at, j.updated_at, c.name, c.logo_url, c.address`

func (r *careerRepository) CreateJobVacancy(ctx context.Context, job *domain.JobVacancy) error {
	_, err := r.exec(ctx,
		`INSERT INTO job_vacancies (id, company_id, tenant_id, title, type, target_role, arrangement, description, requirements, is_active, is_public, salary_min, salary_max, hide_salary, deadline) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15)`,
		job.ID, job.CompanyID, job.TenantID, job.Title, job.Type, job.TargetRole,
		job.Arrangement, job.Description, job.Requirements,
		job.IsActive, job.IsPublic, job.SalaryMin, job.SalaryMax,
		job.HideSalary, job.Deadline,
	)
	return err
}

func (r *careerRepository) GetLocalJobs(ctx context.Context, tenantID uuid.UUID) ([]*domain.JobVacancy, error) {
	rows, err := r.query(ctx,
		`SELECT `+jobSelectFields+` FROM job_vacancies j LEFT JOIN companies c ON c.id = j.company_id WHERE (j.tenant_id = $1 OR j.tenant_id = $2) AND j.is_active = TRUE AND j.deleted_at IS NULL ORDER BY j.created_at DESC`,
		tenantID, tenantID.String(),
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return scanJobs(rows)
}

func (r *careerRepository) GetPublicJobs(ctx context.Context) ([]*domain.JobVacancy, error) {
	rows, err := r.query(ctx,
		`SELECT `+jobSelectFields+` FROM job_vacancies j LEFT JOIN companies c ON c.id = j.company_id WHERE j.is_public = TRUE AND j.is_active = TRUE AND j.deleted_at IS NULL ORDER BY j.created_at DESC`,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return scanJobs(rows)
}

func (r *careerRepository) GetJobByID(ctx context.Context, id uuid.UUID) (*domain.JobVacancy, error) {
	row := r.queryRow(ctx,
		`SELECT `+jobSelectFields+` FROM job_vacancies j LEFT JOIN companies c ON c.id = j.company_id WHERE j.id = $1 AND j.deleted_at IS NULL LIMIT 1`,
		id,
	)
	j, err := scanJob(row)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return j, err
}

func (r *careerRepository) ApplyJob(ctx context.Context, app *domain.JobApplication) error {
	_, err := r.exec(ctx,
		`INSERT INTO job_applications (id, job_vacancy_id, user_id, resume_url, status, applied_at) VALUES ($1,$2,$3,$4,$5,$6)`,
		app.ID, app.JobVacancyID, app.UserID, app.ResumeUrl, app.Status, app.AppliedAt,
	)
	return err
}

func (r *careerRepository) GetMyApplications(ctx context.Context, userID uuid.UUID) ([]*domain.JobApplication, error) {
	rows, err := r.query(ctx,
		`SELECT id, job_vacancy_id, user_id, resume_url, status, applied_at, updated_at FROM job_applications WHERE user_id = $1 ORDER BY applied_at DESC`,
		userID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return scanApplications(rows)
}

func (r *careerRepository) GetApplicationsByJob(ctx context.Context, jobID uuid.UUID) ([]*domain.JobApplication, error) {
	rows, err := r.query(ctx,
		`SELECT id, job_vacancy_id, user_id, resume_url, status, applied_at, updated_at FROM job_applications WHERE job_vacancy_id = $1 ORDER BY applied_at DESC`,
		jobID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return scanApplications(rows)
}

func (r *careerRepository) UpdateApplicationStatus(ctx context.Context, appID uuid.UUID, status domain.JobApplicationStatus) error {
	_, err := r.exec(ctx,
		`UPDATE job_applications SET status = $1, updated_at = NOW() WHERE id = $2`,
		status, appID,
	)
	return err
}

func (r *careerRepository) GetApplicationByID(ctx context.Context, id uuid.UUID) (*domain.JobApplication, error) {
	var a domain.JobApplication
	err := r.queryRow(ctx,
		`SELECT id, job_vacancy_id, user_id, resume_url, status, applied_at, updated_at FROM job_applications WHERE id = $1 LIMIT 1`,
		id,
	).Scan(&a.ID, &a.JobVacancyID, &a.UserID, &a.ResumeUrl, &a.Status, &a.AppliedAt, &a.UpdatedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return &a, err
}

func scanApplications(rows *sql.Rows) ([]*domain.JobApplication, error) {
	var apps []*domain.JobApplication
	for rows.Next() {
		var a domain.JobApplication
		if err := rows.Scan(&a.ID, &a.JobVacancyID, &a.UserID, &a.ResumeUrl, &a.Status, &a.AppliedAt, &a.UpdatedAt); err != nil {
			continue
		}
		apps = append(apps, &a)
	}
	return apps, nil
}
