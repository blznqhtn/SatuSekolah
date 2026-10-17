package requests

import "time"

type CreateAcademicYearRequest struct {
	TenantID  string    `json:"tenant_id" validate:"required,uuid"`
	Name      string    `json:"name" validate:"required"`
	StartDate time.Time `json:"start_date" validate:"required"`
	EndDate   time.Time `json:"end_date" validate:"required"`
	IsActive  bool      `json:"is_active"`
}

type CreateMajorRequest struct {
	TenantID string `json:"tenant_id" validate:"required,uuid"`
	Name     string `json:"name" validate:"required"`
}

type CreateClassRequest struct {
	TenantID   string `json:"tenant_id" validate:"required,uuid"`
	MajorID    string `json:"major_id" validate:"required,uuid"`
	GradeLevel int    `json:"grade_level" validate:"required,number"`
	Name       string `json:"name" validate:"required"`
}

// ... and so on for other academic entities
