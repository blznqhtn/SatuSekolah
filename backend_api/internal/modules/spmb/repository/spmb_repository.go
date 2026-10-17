package repository

import (
	"context"
	"database/sql"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/spmb/domain"
)

type spmbRepository struct {
	db *sql.DB
}

func NewSpmbRepository(db *sql.DB) domain.SpmbRepository {
	return &spmbRepository{db: db}
}

func (r *spmbRepository) GetPublicSchools(ctx context.Context) ([]*domain.PublicSchoolInfo, error) {
	query := `SELECT id, name, address, logo_url FROM tenants`
	rows, err := r.db.QueryContext(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var schools []*domain.PublicSchoolInfo
	for rows.Next() {
		var s domain.PublicSchoolInfo
		var address, logoURL sql.NullString
		if err := rows.Scan(&s.ID, &s.Name, &address, &logoURL); err != nil {
			return nil, err
		}
		s.Address = address.String
		s.LogoURL = logoURL.String
		schools = append(schools, &s)
	}
	return schools, nil
}

func (r *spmbRepository) CreateRegistration(ctx context.Context, reg *domain.SpmbRegistration) error {
	query := `
		INSERT INTO spmb_registrations (
			id, tenant_id, parent_id, spmb_batch_id, major_id, second_major_id,
			student_name, nisn, previous_school, region, gender, religion, photo_url, student_phone,
			father_name, mother_name, father_phone, mother_phone, father_job, mother_job, father_income, mother_income,
			registration_status, created_at
		) VALUES (
			?, ?, ?, ?, ?, ?,
			?, ?, ?, ?, ?, ?, ?, ?,
			?, ?, ?, ?, ?, ?, ?, ?,
			?, ?
		)
	`
	_, err := r.db.ExecContext(ctx, query,
		reg.ID, reg.TenantID, reg.ParentID, reg.SpmbBatchID, reg.MajorID, reg.SecondMajorID,
		reg.StudentName, reg.NISN, reg.PreviousSchool, reg.Region, reg.Gender, reg.Religion, reg.PhotoURL, reg.StudentPhone,
		reg.FatherName, reg.MotherName, reg.FatherPhone, reg.MotherPhone, reg.FatherJob, reg.MotherJob, reg.FatherIncome, reg.MotherIncome,
		reg.RegistrationStatus, reg.CreatedAt,
	)
	return err
}

func (r *spmbRepository) UpdateRegistrationStatus(ctx context.Context, id uuid.UUID, status string) error {
	query := `UPDATE spmb_registrations SET registration_status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?`
	_, err := r.db.ExecContext(ctx, query, status, id)
	return err
}

func (r *spmbRepository) GetMyApplications(ctx context.Context, parentID uuid.UUID) ([]*domain.SpmbRegistration, error) {
	query := `
		SELECT id, tenant_id, parent_id, spmb_batch_id, major_id, second_major_id, invoice_id,
		       student_name, nisn, previous_school, region, gender, religion, photo_url, student_phone,
		       father_name, mother_name, father_phone, mother_phone, father_job, mother_job, father_income, mother_income,
		       registration_status, exam_schedule, created_at, updated_at
		FROM spmb_registrations
		WHERE parent_id = ?
		ORDER BY created_at DESC
	`
	rows, err := r.db.QueryContext(ctx, query, parentID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var apps []*domain.SpmbRegistration
	for rows.Next() {
		var app domain.SpmbRegistration
		var spmbBatchID, majorID, secondMajorID, invoiceID sql.NullString
		var examSchedule, updatedAt sql.NullTime

		if err := rows.Scan(
			&app.ID, &app.TenantID, &app.ParentID, &spmbBatchID, &majorID, &secondMajorID, &invoiceID,
			&app.StudentName, &app.NISN, &app.PreviousSchool, &app.Region, &app.Gender, &app.Religion, &app.PhotoURL, &app.StudentPhone,
			&app.FatherName, &app.MotherName, &app.FatherPhone, &app.MotherPhone, &app.FatherJob, &app.MotherJob, &app.FatherIncome, &app.MotherIncome,
			&app.RegistrationStatus, &examSchedule, &app.CreatedAt, &updatedAt,
		); err != nil {
			return nil, err
		}

		if spmbBatchID.Valid {
			id, _ := uuid.Parse(spmbBatchID.String)
			app.SpmbBatchID = &id
		}
		if majorID.Valid {
			id, _ := uuid.Parse(majorID.String)
			app.MajorID = &id
		}
		if secondMajorID.Valid {
			id, _ := uuid.Parse(secondMajorID.String)
			app.SecondMajorID = &id
		}
		if invoiceID.Valid {
			id, _ := uuid.Parse(invoiceID.String)
			app.InvoiceID = &id
		}
		if examSchedule.Valid {
			app.ExamSchedule = &examSchedule.Time
		}
		if updatedAt.Valid {
			app.UpdatedAt = updatedAt.Time
		}

		apps = append(apps, &app)
	}

	return apps, nil
}
