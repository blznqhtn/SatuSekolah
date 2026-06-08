package requests

type CreateCompanyRequest struct {
	TenantID string `json:"tenant_id" validate:"required,uuid"`
	Name     string `json:"name" validate:"required"`
	Industry string `json:"industry"`
	LogoURL  string `json:"logo_url" validate:"url"`
	Address  string `json:"address"`
}

type CreateJobVacancyRequest struct {
	CompanyID    string `json:"company_id" validate:"required,uuid"`
	Title        string `json:"title" validate:"required"`
	Type         string `json:"type" validate:"required"`
	Arrangement  string `json:"arrangement" validate:"required"`
	Description  string `json:"description" validate:"required"`
	Requirements string `json:"requirements" validate:"required"`
	IsActive     bool   `json:"is_active"`
}

type ApplyJobRequest struct {
	JobVacancyID string `json:"job_vacancy_id" validate:"required,uuid"`
	StudentID    string `json:"student_id" validate:"required,uuid"`
	ResumeURL    string `json:"resume_url" validate:"required,url"`
}
