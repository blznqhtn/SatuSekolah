package repositories

import (
	"context"
	"database/sql"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/academic/entities"
)

type academicRepository struct {
	db *sql.DB
}

func NewAcademicRepository(db *sql.DB) (AcademicYearRepository, MajorRepository, ClassRepository) {
	return &academicRepository{db: db}, &academicRepository{db: db}, &academicRepository{db: db}
}

func (r *academicRepository) Save(ctx context.Context, ay *entities.AcademicYear) error {
	query := `INSERT INTO academic_years (id, tenant_id, name, start_date, end_date, is_active) 
              VALUES ($1, $2, $3, $4, $5, $6)`
	_, err := r.db.ExecContext(ctx, query, ay.ID, ay.TenantID, ay.Name, ay.StartDate, ay.EndDate, ay.IsActive)
	return err
}

func (r *academicRepository) SaveMajor(ctx context.Context, m *entities.Major) error {
	query := `INSERT INTO majors (id, tenant_id, name) 
              VALUES ($1, $2, $3)`
	_, err := r.db.ExecContext(ctx, query, m.ID, m.TenantID, m.Name)
	return err
}

func (r *academicRepository) SaveClass(ctx context.Context, c *entities.Class) error {
	query := `INSERT INTO classes (id, tenant_id, major_id, grade_level, name) 
              VALUES ($1, $2, $3, $4, $5)`
	_, err := r.db.ExecContext(ctx, query, c.ID, c.TenantID, c.MajorID, c.GradeLevel, c.Name)
	return err
}
