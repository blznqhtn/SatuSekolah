package services

import (
	"context"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/academic/entities"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/academic/requests"
)

type AcademicYearService interface {
	CreateAcademicYear(ctx context.Context, req *requests.CreateAcademicYearRequest) (*entities.AcademicYear, error)
}

type MajorService interface {
	CreateMajor(ctx context.Context, req *requests.CreateMajorRequest) (*entities.Major, error)
}

type ClassService interface {
	CreateClass(ctx context.Context, req *requests.CreateClassRequest) (*entities.Class, error)
}

// ... and so on for other academic entities
