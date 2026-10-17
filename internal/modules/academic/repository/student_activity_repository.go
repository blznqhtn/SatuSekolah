package repository

import (
	"context"
	"database/sql"
	"time"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/academic/domain"
)

// =============================================================================
// STUDENT PERMIT REPOSITORY
// =============================================================================

type permitRepository struct {
	db *sql.DB
}

func NewPermitRepository(db *sql.DB) domain.PermitRepository {
	return &permitRepository{db: db}
}

func (r *permitRepository) Create(ctx context.Context, permit *domain.StudentPermit) error {
	if permit.ID == uuid.Nil {
		permit.ID = uuid.New()
	}
	now := time.Now()
	permit.CreatedAt = now
	permit.UpdatedAt = now
	if permit.Status == "" {
		permit.Status = domain.PermitPending
	}

	q := `
		INSERT INTO student_permits 
			(id, tenant_id, student_id, type, reason, start_date, end_date, status, attachment_url, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
	`
	_, err := r.db.ExecContext(ctx, q,
		permit.ID, permit.TenantID, permit.StudentID,
		permit.Type, permit.Reason,
		permit.StartDate, permit.EndDate,
		permit.Status, permit.AttachmentURL,
		permit.CreatedAt, permit.UpdatedAt,
	)
	return err
}

func (r *permitRepository) GetByID(ctx context.Context, id uuid.UUID) (*domain.StudentPermit, error) {
	q := `
		SELECT p.id, p.tenant_id, p.student_id, u.name, p.type, p.reason, 
		       p.start_date, p.end_date, p.status, p.reviewed_by, p.review_note, 
		       p.attachment_url, p.created_at, p.updated_at
		FROM student_permits p
		LEFT JOIN users u ON p.student_id = u.id
		WHERE p.id = $1
	`
	var p domain.StudentPermit
	var reviewedBy sql.NullString
	var reviewNote, attachURL sql.NullString

	err := r.db.QueryRowContext(ctx, q, id).Scan(
		&p.ID, &p.TenantID, &p.StudentID, &p.StudentName,
		&p.Type, &p.Reason, &p.StartDate, &p.EndDate,
		&p.Status, &reviewedBy, &reviewNote, &attachURL,
		&p.CreatedAt, &p.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}
	if reviewedBy.Valid {
		uid, _ := uuid.Parse(reviewedBy.String)
		p.ReviewedBy = &uid
	}
	p.ReviewNote = reviewNote.String
	p.AttachmentURL = attachURL.String
	return &p, nil
}

func (r *permitRepository) GetByStudent(ctx context.Context, tenantID, studentID uuid.UUID) ([]*domain.StudentPermit, error) {
	q := `
		SELECT p.id, p.tenant_id, p.student_id, COALESCE(u.name,''), p.type, p.reason, 
		       p.start_date, p.end_date, p.status, p.reviewed_by, p.review_note, 
		       COALESCE(p.attachment_url,''), p.created_at, p.updated_at
		FROM student_permits p
		LEFT JOIN users u ON p.student_id = u.id
		WHERE p.tenant_id = $1 AND p.student_id = $2
		ORDER BY p.created_at DESC
	`
	rows, err := r.db.QueryContext(ctx, q, tenantID, studentID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return scanPermits(rows)
}

func (r *permitRepository) GetPending(ctx context.Context, tenantID uuid.UUID) ([]*domain.StudentPermit, error) {
	q := `
		SELECT p.id, p.tenant_id, p.student_id, COALESCE(u.name,''), p.type, p.reason, 
		       p.start_date, p.end_date, p.status, p.reviewed_by, p.review_note, 
		       COALESCE(p.attachment_url,''), p.created_at, p.updated_at
		FROM student_permits p
		LEFT JOIN users u ON p.student_id = u.id
		WHERE p.tenant_id = $1 AND p.status = 'PENDING'
		ORDER BY p.created_at ASC
	`
	rows, err := r.db.QueryContext(ctx, q, tenantID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return scanPermits(rows)
}

func (r *permitRepository) UpdateStatus(ctx context.Context, id uuid.UUID, status domain.PermitStatus, reviewedBy uuid.UUID, note string) error {
	q := `UPDATE student_permits SET status = $1, reviewed_by = $2, review_note = $3, updated_at = $4 WHERE id = $5`
	_, err := r.db.ExecContext(ctx, q, status, reviewedBy, note, time.Now(), id)
	return err
}

func scanPermits(rows *sql.Rows) ([]*domain.StudentPermit, error) {
	var permits []*domain.StudentPermit
	for rows.Next() {
		var p domain.StudentPermit
		var reviewedBy sql.NullString
		var reviewNote sql.NullString
		if err := rows.Scan(
			&p.ID, &p.TenantID, &p.StudentID, &p.StudentName,
			&p.Type, &p.Reason, &p.StartDate, &p.EndDate,
			&p.Status, &reviewedBy, &reviewNote, &p.AttachmentURL,
			&p.CreatedAt, &p.UpdatedAt,
		); err != nil {
			return nil, err
		}
		if reviewedBy.Valid {
			uid, _ := uuid.Parse(reviewedBy.String)
			p.ReviewedBy = &uid
		}
		p.ReviewNote = reviewNote.String
		permits = append(permits, &p)
	}
	return permits, nil
}

// =============================================================================
// COUNSELING REPOSITORY
// =============================================================================

type counselingRepository struct {
	db *sql.DB
}

func NewCounselingRepository(db *sql.DB) domain.CounselingRepository {
	return &counselingRepository{db: db}
}

func (r *counselingRepository) Create(ctx context.Context, session *domain.CounselingSession) error {
	if session.ID == uuid.Nil {
		session.ID = uuid.New()
	}
	session.CreatedAt = time.Now()
	if session.Status == "" {
		session.Status = domain.CounselingRequested
	}

	q := `
		INSERT INTO counseling_sessions 
			(id, tenant_id, student_id, topic, description, preferred_date, status, created_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
	`
	_, err := r.db.ExecContext(ctx, q,
		session.ID, session.TenantID, session.StudentID,
		session.Topic, session.Description, session.PreferredDate,
		session.Status, session.CreatedAt,
	)
	return err
}

func (r *counselingRepository) GetByStudent(ctx context.Context, tenantID, studentID uuid.UUID) ([]*domain.CounselingSession, error) {
	q := `
		SELECT cs.id, cs.tenant_id, cs.student_id, COALESCE(u.name,''),
		       cs.counselor_id, COALESCE(cu.name,''),
		       cs.topic, cs.description, cs.preferred_date, cs.scheduled_at, 
		       cs.status, COALESCE(cs.notes,''), cs.created_at
		FROM counseling_sessions cs
		LEFT JOIN users u ON cs.student_id = u.id
		LEFT JOIN users cu ON cs.counselor_id = cu.id
		WHERE cs.tenant_id = $1 AND cs.student_id = $2
		ORDER BY cs.created_at DESC
	`
	rows, err := r.db.QueryContext(ctx, q, tenantID, studentID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return scanCounselingSessions(rows)
}

func (r *counselingRepository) GetAll(ctx context.Context, tenantID uuid.UUID) ([]*domain.CounselingSession, error) {
	q := `
		SELECT cs.id, cs.tenant_id, cs.student_id, COALESCE(u.name,''),
		       cs.counselor_id, COALESCE(cu.name,''),
		       cs.topic, cs.description, cs.preferred_date, cs.scheduled_at,
		       cs.status, COALESCE(cs.notes,''), cs.created_at
		FROM counseling_sessions cs
		LEFT JOIN users u ON cs.student_id = u.id
		LEFT JOIN users cu ON cs.counselor_id = cu.id
		WHERE cs.tenant_id = $1
		ORDER BY cs.created_at DESC
	`
	rows, err := r.db.QueryContext(ctx, q, tenantID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return scanCounselingSessions(rows)
}

func (r *counselingRepository) UpdateStatus(ctx context.Context, id uuid.UUID, status domain.CounselingStatus, counselorID uuid.UUID, scheduledAt *time.Time, notes string) error {
	q := `UPDATE counseling_sessions SET status = $1, counselor_id = $2, scheduled_at = $3, notes = $4 WHERE id = $5`
	_, err := r.db.ExecContext(ctx, q, status, counselorID, scheduledAt, notes, id)
	return err
}

func scanCounselingSessions(rows *sql.Rows) ([]*domain.CounselingSession, error) {
	var sessions []*domain.CounselingSession
	for rows.Next() {
		var s domain.CounselingSession
		var counselorID sql.NullString
		var scheduledAt sql.NullTime
		if err := rows.Scan(
			&s.ID, &s.TenantID, &s.StudentID, &s.StudentName,
			&counselorID, &s.CounselorName,
			&s.Topic, &s.Description, &s.PreferredDate, &scheduledAt,
			&s.Status, &s.Notes, &s.CreatedAt,
		); err != nil {
			return nil, err
		}
		if counselorID.Valid {
			uid, _ := uuid.Parse(counselorID.String)
			s.CounselorID = &uid
		}
		if scheduledAt.Valid {
			s.ScheduledAt = &scheduledAt.Time
		}
		sessions = append(sessions, &s)
	}
	return sessions, nil
}

// =============================================================================
// EXTRACURRICULAR REPOSITORY
// =============================================================================

type extracurricularRepository struct {
	db *sql.DB
}

func NewExtracurricularRepository(db *sql.DB) domain.ExtracurricularRepository {
	return &extracurricularRepository{db: db}
}

func (r *extracurricularRepository) GetAll(ctx context.Context, tenantID uuid.UUID) ([]*domain.Extracurricular, error) {
	q := `
		SELECT e.id, e.tenant_id, e.name, e.description, COALESCE(e.coach_name,''), 
		       COALESCE(e.schedule,''), e.max_members, 
		       (SELECT COUNT(*) FROM extracurricular_registrations er 
		        WHERE er.extracurricular_id = e.id AND er.status = 'APPROVED') as total_member,
		       e.status, COALESCE(e.image_url,''), e.created_at
		FROM extracurriculars e
		WHERE e.tenant_id = $1 AND e.status = 'ACTIVE'
		ORDER BY e.name ASC
	`
	rows, err := r.db.QueryContext(ctx, q, tenantID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var extras []*domain.Extracurricular
	for rows.Next() {
		var e domain.Extracurricular
		if err := rows.Scan(
			&e.ID, &e.TenantID, &e.Name, &e.Description, &e.CoachName,
			&e.Schedule, &e.MaxMembers, &e.TotalMember, &e.Status, &e.ImageURL, &e.CreatedAt,
		); err != nil {
			return nil, err
		}
		extras = append(extras, &e)
	}
	return extras, nil
}

func (r *extracurricularRepository) GetByID(ctx context.Context, id uuid.UUID) (*domain.Extracurricular, error) {
	q := `
		SELECT id, tenant_id, name, description, COALESCE(coach_name,''), 
		       COALESCE(schedule,''), max_members, 0, status, COALESCE(image_url,''), created_at
		FROM extracurriculars WHERE id = $1
	`
	var e domain.Extracurricular
	err := r.db.QueryRowContext(ctx, q, id).Scan(
		&e.ID, &e.TenantID, &e.Name, &e.Description, &e.CoachName,
		&e.Schedule, &e.MaxMembers, &e.TotalMember, &e.Status, &e.ImageURL, &e.CreatedAt,
	)
	return &e, err
}

func (r *extracurricularRepository) Create(ctx context.Context, extra *domain.Extracurricular) error {
	if extra.ID == uuid.Nil {
		extra.ID = uuid.New()
	}
	extra.CreatedAt = time.Now()
	if extra.Status == "" {
		extra.Status = domain.ExtraActive
	}
	q := `
		INSERT INTO extracurriculars 
			(id, tenant_id, name, description, coach_name, schedule, max_members, status, image_url, created_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
	`
	_, err := r.db.ExecContext(ctx, q,
		extra.ID, extra.TenantID, extra.Name, extra.Description,
		extra.CoachName, extra.Schedule, extra.MaxMembers,
		extra.Status, extra.ImageURL, extra.CreatedAt,
	)
	return err
}

func (r *extracurricularRepository) Register(ctx context.Context, reg *domain.ExtracurricularRegistration) error {
	if reg.ID == uuid.Nil {
		reg.ID = uuid.New()
	}
	reg.RegisteredAt = time.Now()
	if reg.Status == "" {
		reg.Status = domain.RegPending
	}
	q := `
		INSERT INTO extracurricular_registrations 
			(id, tenant_id, student_id, extracurricular_id, status, registered_at)
		VALUES ($1, $2, $3, $4, $5, $6)
	`
	_, err := r.db.ExecContext(ctx, q,
		reg.ID, reg.TenantID, reg.StudentID,
		reg.ExtracurricularID, reg.Status, reg.RegisteredAt,
	)
	return err
}

func (r *extracurricularRepository) GetMyRegistrations(ctx context.Context, tenantID, studentID uuid.UUID) ([]*domain.ExtracurricularRegistration, error) {
	q := `
		SELECT er.id, er.tenant_id, er.student_id, COALESCE(u.name,''),
		       er.extracurricular_id, COALESCE(e.name,''), er.status, er.registered_at
		FROM extracurricular_registrations er
		LEFT JOIN users u ON er.student_id = u.id
		LEFT JOIN extracurriculars e ON er.extracurricular_id = e.id
		WHERE er.tenant_id = $1 AND er.student_id = $2
		ORDER BY er.registered_at DESC
	`
	rows, err := r.db.QueryContext(ctx, q, tenantID, studentID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return scanRegistrations(rows)
}

func (r *extracurricularRepository) GetRegistrationsByExtra(ctx context.Context, extraID uuid.UUID) ([]*domain.ExtracurricularRegistration, error) {
	q := `
		SELECT er.id, er.tenant_id, er.student_id, COALESCE(u.name,''),
		       er.extracurricular_id, COALESCE(e.name,''), er.status, er.registered_at
		FROM extracurricular_registrations er
		LEFT JOIN users u ON er.student_id = u.id
		LEFT JOIN extracurriculars e ON er.extracurricular_id = e.id
		WHERE er.extracurricular_id = $1
		ORDER BY er.registered_at ASC
	`
	rows, err := r.db.QueryContext(ctx, q, extraID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return scanRegistrations(rows)
}

func (r *extracurricularRepository) UpdateRegistrationStatus(ctx context.Context, regID uuid.UUID, status domain.RegistrationStatus) error {
	_, err := r.db.ExecContext(ctx,
		`UPDATE extracurricular_registrations SET status = $1 WHERE id = $2`,
		status, regID,
	)
	return err
}

func scanRegistrations(rows *sql.Rows) ([]*domain.ExtracurricularRegistration, error) {
	var regs []*domain.ExtracurricularRegistration
	for rows.Next() {
		var reg domain.ExtracurricularRegistration
		if err := rows.Scan(
			&reg.ID, &reg.TenantID, &reg.StudentID, &reg.StudentName,
			&reg.ExtracurricularID, &reg.ExtracurricularName,
			&reg.Status, &reg.RegisteredAt,
		); err != nil {
			return nil, err
		}
		regs = append(regs, &reg)
	}
	return regs, nil
}
