package repository

import (
	"context"
	"database/sql"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/health/domain"
)

type healthRepository struct {
	db *sql.DB
}

func NewHealthRepository(db *sql.DB) domain.HealthRepository {
	return &healthRepository{db: db}
}

func (r *healthRepository) GetSetting(ctx context.Context, tenantID uuid.UUID) (*domain.HealthSetting, error) {
	var s domain.HealthSetting
	err := r.db.QueryRowContext(ctx, "SELECT tenant_id, health_admin_user_id, created_at FROM health_settings WHERE tenant_id = ?", tenantID).
		Scan(&s.TenantID, &s.HealthAdminUserID, &s.CreatedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return &s, err
}

func (r *healthRepository) UpsertSetting(ctx context.Context, s *domain.HealthSetting) error {
	_, err := r.db.ExecContext(ctx, `
		INSERT INTO health_settings (tenant_id, health_admin_user_id, created_at) 
		VALUES (?, ?, ?)
		ON DUPLICATE KEY UPDATE health_admin_user_id = VALUES(health_admin_user_id)
	`, s.TenantID, s.HealthAdminUserID, s.CreatedAt)
	return err
}

func (r *healthRepository) CreateRecord(ctx context.Context, rec *domain.HealthRecord) error {
	if rec.ID == uuid.Nil {
		rec.ID = uuid.New()
	}
	_, err := r.db.ExecContext(ctx, `
		INSERT INTO health_records 
		(id, tenant_id, user_id, record_type, date, height, weight, hearing, vision, dental, hemoglobin, notes, ai_recommendation, updated_by)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
	`, rec.ID, rec.TenantID, rec.UserID, rec.RecordType, rec.Date, rec.Height, rec.Weight, rec.Hearing, rec.Vision, rec.Dental, rec.Hemoglobin, rec.Notes, rec.AIRecommendation, rec.UpdatedBy)
	return err
}

func (r *healthRepository) GetRecordsByUser(ctx context.Context, userID uuid.UUID) ([]*domain.HealthRecord, error) {
	rows, err := r.db.QueryContext(ctx, `
		SELECT id, tenant_id, user_id, record_type, date, height, weight, hearing, vision, dental, hemoglobin, notes, ai_recommendation, created_at, updated_by
		FROM health_records WHERE user_id = ? ORDER BY date DESC
	`, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var recs []*domain.HealthRecord
	for rows.Next() {
		var rec domain.HealthRecord
		err := rows.Scan(&rec.ID, &rec.TenantID, &rec.UserID, &rec.RecordType, &rec.Date, &rec.Height, &rec.Weight, &rec.Hearing, &rec.Vision, &rec.Dental, &rec.Hemoglobin, &rec.Notes, &rec.AIRecommendation, &rec.CreatedAt, &rec.UpdatedBy)
		if err != nil {
			return nil, err
		}
		recs = append(recs, &rec)
	}
	return recs, nil
}

func (r *healthRepository) CreateCycle(ctx context.Context, cycle *domain.MenstrualCycle) error {
	if cycle.ID == uuid.Nil {
		cycle.ID = uuid.New()
	}
	_, err := r.db.ExecContext(ctx, `
		INSERT INTO menstrual_cycles (id, tenant_id, user_id, start_date, symptoms, ai_advice, status)
		VALUES (?, ?, ?, ?, ?, ?, ?)
	`, cycle.ID, cycle.TenantID, cycle.UserID, cycle.StartDate, cycle.Symptoms, cycle.AIAdvice, cycle.Status)
	return err
}

func (r *healthRepository) GetActiveCycle(ctx context.Context, userID uuid.UUID) (*domain.MenstrualCycle, error) {
	var c domain.MenstrualCycle
	err := r.db.QueryRowContext(ctx, `
		SELECT id, tenant_id, user_id, start_date, end_date, symptoms, ai_advice, status, created_at, updated_at
		FROM menstrual_cycles WHERE user_id = ? AND status IN ('ONGOING', 'BLOCKED_OVERDUE')
		ORDER BY start_date DESC LIMIT 1
	`, userID).Scan(&c.ID, &c.TenantID, &c.UserID, &c.StartDate, &c.EndDate, &c.Symptoms, &c.AIAdvice, &c.Status, &c.CreatedAt, &c.UpdatedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return &c, err
}

func (r *healthRepository) UpdateCycle(ctx context.Context, cycle *domain.MenstrualCycle) error {
	_, err := r.db.ExecContext(ctx, `
		UPDATE menstrual_cycles SET end_date = ?, status = ?, updated_at = NOW() WHERE id = ?
	`, cycle.EndDate, cycle.Status, cycle.ID)
	return err
}

func (r *healthRepository) CreateRibbon(ctx context.Context, rb *domain.RibbonBorrowing) error {
	if rb.ID == uuid.Nil {
		rb.ID = uuid.New()
	}
	_, err := r.db.ExecContext(ctx, `
		INSERT INTO ribbon_borrowings (id, tenant_id, user_id, cycle_id, expected_return_at, status)
		VALUES (?, ?, ?, ?, ?, ?)
	`, rb.ID, rb.TenantID, rb.UserID, rb.CycleID, rb.ExpectedReturnAt, rb.Status)
	return err
}

func (r *healthRepository) GetActiveRibbon(ctx context.Context, userID uuid.UUID) (*domain.RibbonBorrowing, error) {
	var rb domain.RibbonBorrowing
	err := r.db.QueryRowContext(ctx, `
		SELECT id, tenant_id, user_id, cycle_id, borrowed_at, expected_return_at, returned_at, status, sanction_notes, handled_by
		FROM ribbon_borrowings WHERE user_id = ? AND status IN ('BORROWED', 'OVERDUE')
		ORDER BY borrowed_at DESC LIMIT 1
	`, userID).Scan(&rb.ID, &rb.TenantID, &rb.UserID, &rb.CycleID, &rb.BorrowedAt, &rb.ExpectedReturnAt, &rb.ReturnedAt, &rb.Status, &rb.SanctionNotes, &rb.HandledBy)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return &rb, err
}

func (r *healthRepository) UpdateRibbon(ctx context.Context, rb *domain.RibbonBorrowing) error {
	_, err := r.db.ExecContext(ctx, `
		UPDATE ribbon_borrowings SET returned_at = ?, status = ?, sanction_notes = ?, handled_by = ? WHERE id = ?
	`, rb.ReturnedAt, rb.Status, rb.SanctionNotes, rb.HandledBy, rb.ID)
	return err
}

func (r *healthRepository) GetOverdueCyclesAndRibbons(ctx context.Context, tenantID uuid.UUID) ([]*domain.MenstrualCycle, []*domain.RibbonBorrowing, error) {
	// 1. Overdue cycles: ONGOING but started > 7 days ago
	cycleRows, err := r.db.QueryContext(ctx, `
		SELECT id, tenant_id, user_id, start_date, end_date, symptoms, ai_advice, status, created_at, updated_at
		FROM menstrual_cycles 
		WHERE tenant_id = ? AND status IN ('ONGOING', 'BLOCKED_OVERDUE') AND start_date <= DATE_SUB(NOW(), INTERVAL 7 DAY)
		ORDER BY start_date ASC
	`, tenantID)
	if err != nil {
		return nil, nil, err
	}
	defer cycleRows.Close()

	var cycles []*domain.MenstrualCycle
	for cycleRows.Next() {
		var c domain.MenstrualCycle
		if err := cycleRows.Scan(&c.ID, &c.TenantID, &c.UserID, &c.StartDate, &c.EndDate, &c.Symptoms, &c.AIAdvice, &c.Status, &c.CreatedAt, &c.UpdatedAt); err != nil {
			return nil, nil, err
		}
		cycles = append(cycles, &c)
	}

	// 2. Overdue ribbons: BORROWED but past expected_return_at
	ribbonRows, err := r.db.QueryContext(ctx, `
		SELECT id, tenant_id, user_id, cycle_id, borrowed_at, expected_return_at, returned_at, status, sanction_notes, handled_by
		FROM ribbon_borrowings
		WHERE tenant_id = ? AND status IN ('BORROWED', 'OVERDUE') AND expected_return_at <= NOW()
		ORDER BY borrowed_at ASC
	`, tenantID)
	if err != nil {
		return cycles, nil, err
	}
	defer ribbonRows.Close()

	var ribbons []*domain.RibbonBorrowing
	for ribbonRows.Next() {
		var rb domain.RibbonBorrowing
		if err := ribbonRows.Scan(&rb.ID, &rb.TenantID, &rb.UserID, &rb.CycleID, &rb.BorrowedAt, &rb.ExpectedReturnAt, &rb.ReturnedAt, &rb.Status, &rb.SanctionNotes, &rb.HandledBy); err != nil {
			return cycles, nil, err
		}
		ribbons = append(ribbons, &rb)
	}

	return cycles, ribbons, nil
}

// ==========================================
// UKS Health Endpoints
// ==========================================

func (r *healthRepository) CreateHealthCheckup(ctx context.Context, checkup *domain.HealthCheckup) error {
	if checkup.ID == uuid.Nil {
		checkup.ID = uuid.New()
	}
	_, err := r.db.ExecContext(ctx, `
		INSERT INTO health_checkups 
		(id, tenant_id, student_id, examiner_id, date, temperature, blood_pressure, weight, height, complaint, diagnosis, treatment, notes)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
	`, checkup.ID, checkup.TenantID, checkup.StudentID, checkup.ExaminerID, checkup.Date, checkup.Temperature, checkup.BloodPressure, checkup.Weight, checkup.Height, checkup.Complaint, checkup.Diagnosis, checkup.Treatment, checkup.Notes)
	return err
}

func (r *healthRepository) GetStudentCheckups(ctx context.Context, tenantID, studentID uuid.UUID) ([]*domain.HealthCheckup, error) {
	rows, err := r.db.QueryContext(ctx, `
		SELECT 
			c.id, c.tenant_id, c.student_id, c.examiner_id, c.date, c.temperature, 
			c.blood_pressure, c.weight, c.height, c.complaint, c.diagnosis, 
			c.treatment, c.notes, c.created_at, c.updated_at,
			COALESCE(u.name, 'Petugas UKS') as examiner_name
		FROM health_checkups c
		LEFT JOIN users u ON c.examiner_id = u.id
		WHERE c.tenant_id = ? AND c.student_id = ?
		ORDER BY c.date DESC
	`, tenantID, studentID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var list []*domain.HealthCheckup
	for rows.Next() {
		var c domain.HealthCheckup
		var examinerName sql.NullString
		var updated sql.NullTime
		if err := rows.Scan(&c.ID, &c.TenantID, &c.StudentID, &c.ExaminerID, &c.Date, &c.Temperature, &c.BloodPressure, &c.Weight, &c.Height, &c.Complaint, &c.Diagnosis, &c.Treatment, &c.Notes, &c.CreatedAt, &updated, &examinerName); err != nil {
			return nil, err
		}
		if updated.Valid {
			c.UpdatedAt = updated.Time
		}
		if examinerName.Valid {
			c.ExaminerName = examinerName.String
		}
		list = append(list, &c)
	}
	return list, nil
}

func (r *healthRepository) GetLatestCheckup(ctx context.Context, tenantID, studentID uuid.UUID) (*domain.HealthCheckup, error) {
	var c domain.HealthCheckup
	var examinerName sql.NullString
	var updated sql.NullTime
	err := r.db.QueryRowContext(ctx, `
		SELECT 
			c.id, c.tenant_id, c.student_id, c.examiner_id, c.date, c.temperature, 
			c.blood_pressure, c.weight, c.height, c.complaint, c.diagnosis, 
			c.treatment, c.notes, c.created_at, c.updated_at,
			COALESCE(u.name, 'Petugas UKS') as examiner_name
		FROM health_checkups c
		LEFT JOIN users u ON c.examiner_id = u.id
		WHERE c.tenant_id = ? AND c.student_id = ?
		ORDER BY c.date DESC LIMIT 1
	`, tenantID, studentID).Scan(&c.ID, &c.TenantID, &c.StudentID, &c.ExaminerID, &c.Date, &c.Temperature, &c.BloodPressure, &c.Weight, &c.Height, &c.Complaint, &c.Diagnosis, &c.Treatment, &c.Notes, &c.CreatedAt, &updated, &examinerName)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	if updated.Valid {
		c.UpdatedAt = updated.Time
	}
	if examinerName.Valid {
		c.ExaminerName = examinerName.String
	}
	return &c, nil
}

func (r *healthRepository) GetMedicalHistory(ctx context.Context, tenantID, studentID uuid.UUID) (*domain.MedicalHistory, error) {
	var h domain.MedicalHistory
	var updated sql.NullTime
	err := r.db.QueryRowContext(ctx, `
		SELECT id, tenant_id, student_id, blood_type, allergies, chronic_diseases, special_conditions, updated_at
		FROM health_medical_history
		WHERE tenant_id = ? AND student_id = ?
	`, tenantID, studentID).Scan(&h.ID, &h.TenantID, &h.StudentID, &h.BloodType, &h.Allergies, &h.ChronicDiseases, &h.SpecialConditions, &updated)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	if updated.Valid {
		h.UpdatedAt = updated.Time
	}
	return &h, nil
}

func (r *healthRepository) UpsertMedicalHistory(ctx context.Context, history *domain.MedicalHistory) error {
	if history.ID == uuid.Nil {
		history.ID = uuid.New()
	}
	_, err := r.db.ExecContext(ctx, `
		INSERT INTO health_medical_history 
		(id, tenant_id, student_id, blood_type, allergies, chronic_diseases, special_conditions, updated_at)
		VALUES (?, ?, ?, ?, ?, ?, ?, NOW())
		ON DUPLICATE KEY UPDATE 
			blood_type = VALUES(blood_type),
			allergies = VALUES(allergies),
			chronic_diseases = VALUES(chronic_diseases),
			special_conditions = VALUES(special_conditions),
			updated_at = NOW()
	`, history.ID, history.TenantID, history.StudentID, history.BloodType, history.Allergies, history.ChronicDiseases, history.SpecialConditions)
	return err
}
