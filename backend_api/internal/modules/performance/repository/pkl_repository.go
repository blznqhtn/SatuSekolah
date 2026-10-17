package repository

import (
	"context"
	"database/sql"
	"time"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/performance/domain"
)

type pklRepository struct {
	db *sql.DB
	tx *sql.Tx
}

func NewPklRepository(db *sql.DB) domain.PklRepository {
	return &pklRepository{db: db}
}

func (r *pklRepository) ExecTx(ctx context.Context, fn func(repo domain.PklRepository) error) error {
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	txRepo := &pklRepository{db: r.db, tx: tx}
	if err := fn(txRepo); err != nil {
		_ = tx.Rollback()
		return err
	}
	return tx.Commit()
}

func (r *pklRepository) exec(ctx context.Context, q string, args ...interface{}) (sql.Result, error) {
	if r.tx != nil {
		return r.tx.ExecContext(ctx, q, args...)
	}
	return r.db.ExecContext(ctx, q, args...)
}

func (r *pklRepository) queryRow(ctx context.Context, q string, args ...interface{}) *sql.Row {
	if r.tx != nil {
		return r.tx.QueryRowContext(ctx, q, args...)
	}
	return r.db.QueryRowContext(ctx, q, args...)
}

func (r *pklRepository) query(ctx context.Context, q string, args ...interface{}) (*sql.Rows, error) {
	if r.tx != nil {
		return r.tx.QueryContext(ctx, q, args...)
	}
	return r.db.QueryContext(ctx, q, args...)
}

// ------------------------------------------
// Existing PKL Monitoring
// ------------------------------------------

func (r *pklRepository) GetSetting(ctx context.Context, tenantID uuid.UUID) (*domain.PerformanceSetting, error) {
	var s domain.PerformanceSetting
	err := r.queryRow(ctx, "SELECT tenant_id, principal_staff_id, created_at FROM performance_settings WHERE tenant_id = ?", tenantID).
		Scan(&s.TenantID, &s.PrincipalStaffID, &s.CreatedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return &s, err
}

func (r *pklRepository) UpsertSetting(ctx context.Context, s *domain.PerformanceSetting) error {
	_, err := r.exec(ctx, `
		INSERT INTO performance_settings (tenant_id, principal_staff_id, created_at) 
		VALUES (?, ?, ?)
		ON DUPLICATE KEY UPDATE principal_staff_id = VALUES(principal_staff_id)
	`, s.TenantID, s.PrincipalStaffID, s.CreatedAt)
	return err
}

func (r *pklRepository) CreateMonitoring(ctx context.Context, pkl *domain.PklMonitoring) error {
	if pkl.ID == uuid.Nil {
		pkl.ID = uuid.New()
	}
	_, err := r.exec(ctx, `
		INSERT INTO pkl_monitorings (id, tenant_id, student_id, supervisor_staff_id, documentation_url, notes, status)
		VALUES (?, ?, ?, ?, ?, ?, ?)
	`, pkl.ID, pkl.TenantID, pkl.StudentID, pkl.SupervisorStaffID, pkl.DocumentationURL, pkl.Notes, pkl.Status)
	return err
}

func (r *pklRepository) GetMonitoring(ctx context.Context, pklID uuid.UUID) (*domain.PklMonitoring, error) {
	var p domain.PklMonitoring
	err := r.queryRow(ctx, `
		SELECT id, tenant_id, student_id, supervisor_staff_id, documentation_url, notes, status, principal_score, principal_notes, evaluated_at, created_at
		FROM pkl_monitorings WHERE id = ?
	`, pklID).Scan(&p.ID, &p.TenantID, &p.StudentID, &p.SupervisorStaffID, &p.DocumentationURL, &p.Notes, &p.Status, &p.PrincipalScore, &p.PrincipalNotes, &p.EvaluatedAt, &p.CreatedAt)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	return &p, nil
}

func (r *pklRepository) UpdateMonitoringEvaluation(ctx context.Context, pklID uuid.UUID, score float64, notes string, status domain.PklStatus) error {
	now := time.Now()
	_, err := r.exec(ctx, `
		UPDATE pkl_monitorings SET principal_score=?, principal_notes=?, status=?, evaluated_at=? WHERE id=?
	`, score, notes, status, now, pklID)
	return err
}

// ------------------------------------------
// Mentorship Assignments
// ------------------------------------------

func (r *pklRepository) AssignMentor(ctx context.Context, mentorships []*domain.PklMentorship) error {
	if len(mentorships) == 0 {
		return nil
	}
	for _, m := range mentorships {
		if m.ID == uuid.Nil {
			m.ID = uuid.New()
		}
		if m.CreatedAt.IsZero() {
			m.CreatedAt = time.Now()
		}
		// Insert or update on duplicate (MySQL style)
		q := `
			INSERT INTO pkl_mentorships (id, tenant_id, academic_year_id, student_id, mentor_id, created_at)
			VALUES (?, ?, ?, ?, ?, ?)
			ON DUPLICATE KEY UPDATE mentor_id = VALUES(mentor_id)
		`
		_, err := r.exec(ctx, q, m.ID, m.TenantID, m.AcademicYearID, m.StudentID, m.MentorID, m.CreatedAt)
		if err != nil {
			return err
		}
	}
	return nil
}

func (r *pklRepository) GetMentorshipByStudent(ctx context.Context, studentID uuid.UUID) (*domain.PklMentorship, error) {
	q := `SELECT id, tenant_id, academic_year_id, student_id, mentor_id, created_at FROM pkl_mentorships WHERE student_id = ? LIMIT 1`
	var m domain.PklMentorship
	err := r.queryRow(ctx, q, studentID).Scan(&m.ID, &m.TenantID, &m.AcademicYearID, &m.StudentID, &m.MentorID, &m.CreatedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return &m, err
}

func (r *pklRepository) GetMentorshipsByMentor(ctx context.Context, mentorID uuid.UUID, academicYearID uuid.UUID) ([]*domain.PklMentorship, error) {
	var rows *sql.Rows
	var err error
	if academicYearID == uuid.Nil {
		rows, err = r.query(ctx, `SELECT id, tenant_id, academic_year_id, student_id, mentor_id, created_at FROM pkl_mentorships WHERE mentor_id = ?`, mentorID)
	} else {
		rows, err = r.query(ctx, `SELECT id, tenant_id, academic_year_id, student_id, mentor_id, created_at FROM pkl_mentorships WHERE mentor_id = ? AND academic_year_id = ?`, mentorID, academicYearID)
	}
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var res []*domain.PklMentorship
	for rows.Next() {
		var m domain.PklMentorship
		if err := rows.Scan(&m.ID, &m.TenantID, &m.AcademicYearID, &m.StudentID, &m.MentorID, &m.CreatedAt); err != nil {
			return nil, err
		}
		res = append(res, &m)
	}
	return res, nil
}

// ------------------------------------------
// Mentoring Schedules
// ------------------------------------------

func (r *pklRepository) CreateSchedule(ctx context.Context, schedule *domain.PklMentoringSchedule) error {
	if schedule.ID == uuid.Nil {
		schedule.ID = uuid.New()
	}
	if schedule.CreatedAt.IsZero() {
		schedule.CreatedAt = time.Now()
	}
	q := `INSERT INTO pkl_mentoring_schedules (id, mentorship_id, schedule_date, zoom_link, mentor_notes, created_at) VALUES (?, ?, ?, ?, ?, ?)`
	_, err := r.exec(ctx, q, schedule.ID, schedule.MentorshipID, schedule.ScheduleDate, schedule.ZoomLink, schedule.MentorNotes, schedule.CreatedAt)
	return err
}

func (r *pklRepository) GetScheduleByID(ctx context.Context, id uuid.UUID) (*domain.PklMentoringSchedule, error) {
	q := `SELECT id, mentorship_id, schedule_date, zoom_link, mentor_notes, created_at FROM pkl_mentoring_schedules WHERE id = ?`
	var s domain.PklMentoringSchedule
	var zoom, notes sql.NullString
	err := r.queryRow(ctx, q, id).Scan(&s.ID, &s.MentorshipID, &s.ScheduleDate, &zoom, &notes, &s.CreatedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if zoom.Valid {
		s.ZoomLink = &zoom.String
	}
	if notes.Valid {
		s.MentorNotes = &notes.String
	}
	return &s, err
}

func (r *pklRepository) GetSchedulesByMentorship(ctx context.Context, mentorshipID uuid.UUID) ([]*domain.PklMentoringSchedule, error) {
	q := `SELECT id, mentorship_id, schedule_date, zoom_link, mentor_notes, created_at FROM pkl_mentoring_schedules WHERE mentorship_id = ? ORDER BY schedule_date ASC`
	rows, err := r.query(ctx, q, mentorshipID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var res []*domain.PklMentoringSchedule
	for rows.Next() {
		var s domain.PklMentoringSchedule
		var zoom, notes sql.NullString
		if err := rows.Scan(&s.ID, &s.MentorshipID, &s.ScheduleDate, &zoom, &notes, &s.CreatedAt); err != nil {
			return nil, err
		}
		if zoom.Valid {
			s.ZoomLink = &zoom.String
		}
		if notes.Valid {
			s.MentorNotes = &notes.String
		}
		res = append(res, &s)
	}
	return res, nil
}

// ------------------------------------------
// Journals
// ------------------------------------------

func (r *pklRepository) SaveJournal(ctx context.Context, journal *domain.PklJournal) error {
	if journal.ID == uuid.Nil {
		journal.ID = uuid.New()
	}
	if journal.CreatedAt.IsZero() {
		journal.CreatedAt = time.Now()
	}
	now := time.Now()
	journal.UpdatedAt = &now

	q := `
		INSERT INTO pkl_journals (id, schedule_id, description, document_urls, status, feedback, created_at, updated_at)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?)
		ON DUPLICATE KEY UPDATE
			description = VALUES(description),
			document_urls = VALUES(document_urls),
			status = VALUES(status),
			feedback = VALUES(feedback),
			updated_at = VALUES(updated_at)
	`
	_, err := r.exec(ctx, q, journal.ID, journal.ScheduleID, journal.Description, journal.DocumentURLs, journal.Status, journal.Feedback, journal.CreatedAt, journal.UpdatedAt)
	return err
}

func (r *pklRepository) GetJournalBySchedule(ctx context.Context, scheduleID uuid.UUID) (*domain.PklJournal, error) {
	q := `SELECT id, schedule_id, description, document_urls, status, feedback, created_at, updated_at FROM pkl_journals WHERE schedule_id = ? LIMIT 1`
	var j domain.PklJournal
	var feedback sql.NullString
	err := r.queryRow(ctx, q, scheduleID).Scan(&j.ID, &j.ScheduleID, &j.Description, &j.DocumentURLs, &j.Status, &feedback, &j.CreatedAt, &j.UpdatedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if feedback.Valid {
		j.Feedback = &feedback.String
	}
	return &j, err
}

func (r *pklRepository) GetJournalByID(ctx context.Context, id uuid.UUID) (*domain.PklJournal, error) {
	q := `SELECT id, schedule_id, description, document_urls, status, feedback, created_at, updated_at FROM pkl_journals WHERE id = ? LIMIT 1`
	var j domain.PklJournal
	var feedback sql.NullString
	err := r.queryRow(ctx, q, id).Scan(&j.ID, &j.ScheduleID, &j.Description, &j.DocumentURLs, &j.Status, &feedback, &j.CreatedAt, &j.UpdatedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if feedback.Valid {
		j.Feedback = &feedback.String
	}
	return &j, err
}

// ------------------------------------------
// Final Reports & Settings
// ------------------------------------------

func (r *pklRepository) UpsertFinalReportSetting(ctx context.Context, setting *domain.PklFinalReportSetting) error {
	if setting.ID == uuid.Nil {
		setting.ID = uuid.New()
	}
	q := `
		INSERT INTO pkl_final_report_settings (id, tenant_id, target_type, target_id, start_date, end_date)
		VALUES (?, ?, ?, ?, ?, ?)
		ON DUPLICATE KEY UPDATE
			start_date = VALUES(start_date),
			end_date = VALUES(end_date)
	`
	_, err := r.exec(ctx, q, setting.ID, setting.TenantID, setting.TargetType, setting.TargetID, setting.StartDate, setting.EndDate)
	return err
}

func (r *pklRepository) GetFinalReportSetting(ctx context.Context, tenantID uuid.UUID, studentClassID uuid.UUID, studentMajorID uuid.UUID) (*domain.PklFinalReportSetting, error) {
	// Simple lookup logic for MVP: find specific class or major, or ALL
	q := `SELECT id, tenant_id, target_type, target_id, start_date, end_date FROM pkl_final_report_settings 
	      WHERE tenant_id = ? AND (
			  (target_type = 'CLASS' AND target_id = ?) OR 
			  (target_type = 'MAJOR' AND target_id = ?) OR 
			  (target_type = 'ALL')
		  )
		  ORDER BY CASE WHEN target_type='CLASS' THEN 1 WHEN target_type='MAJOR' THEN 2 ELSE 3 END
		  LIMIT 1
	`
	var s domain.PklFinalReportSetting
	var targetID sql.NullString
	err := r.queryRow(ctx, q, tenantID, studentClassID, studentMajorID).Scan(&s.ID, &s.TenantID, &s.TargetType, &targetID, &s.StartDate, &s.EndDate)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if targetID.Valid && targetID.String != "" {
		id, _ := uuid.Parse(targetID.String)
		s.TargetID = &id
	}
	return &s, err
}

func (r *pklRepository) SaveFinalReport(ctx context.Context, report *domain.PklFinalReport) error {
	if report.ID == uuid.Nil {
		report.ID = uuid.New()
	}
	if report.CreatedAt.IsZero() {
		report.CreatedAt = time.Now()
	}
	now := time.Now()
	report.UpdatedAt = &now
	q := `
		INSERT INTO pkl_final_reports (id, student_id, document_url, status, notes, approved_by, created_at, updated_at)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?)
		ON DUPLICATE KEY UPDATE
			document_url = VALUES(document_url),
			status = VALUES(status),
			notes = VALUES(notes),
			approved_by = VALUES(approved_by),
			updated_at = VALUES(updated_at)
	`
	_, err := r.exec(ctx, q, report.ID, report.StudentID, report.DocumentURL, report.Status, report.Notes, report.ApprovedBy, report.CreatedAt, report.UpdatedAt)
	return err
}

func (r *pklRepository) GetFinalReportByID(ctx context.Context, id uuid.UUID) (*domain.PklFinalReport, error) {
	q := `SELECT id, student_id, document_url, status, notes, approved_by, created_at, updated_at FROM pkl_final_reports WHERE id = ? LIMIT 1`
	var s domain.PklFinalReport
	var notes, app sql.NullString
	err := r.queryRow(ctx, q, id).Scan(&s.ID, &s.StudentID, &s.DocumentURL, &s.Status, &notes, &app, &s.CreatedAt, &s.UpdatedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if notes.Valid {
		s.Notes = &notes.String
	}
	if app.Valid && app.String != "" {
		appID, _ := uuid.Parse(app.String)
		s.ApprovedBy = &appID
	}
	return &s, err
}
