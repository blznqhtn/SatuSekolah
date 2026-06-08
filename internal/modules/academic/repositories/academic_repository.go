package repositories

import (
	"context"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/academic/entities"
)

type AcademicYearRepository interface {
	Save(ctx context.Context, ay *entities.AcademicYear) error
}

type MajorRepository interface {
	SaveMajor(ctx context.Context, m *entities.Major) error
}

type ClassRepository interface {
	SaveClass(ctx context.Context, c *entities.Class) error
}

// ... and so on for other academic entities
