package services

import (
	"context"
	"time"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/academic/entities"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/academic/repositories"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/academic/requests"
)

type academicService struct {
	academicYearRepo repositories.AcademicYearRepository
	majorRepo        repositories.MajorRepository
	classRepo        repositories.ClassRepository
}

func NewAcademicService(
	academicYearRepo repositories.AcademicYearRepository,
	majorRepo repositories.MajorRepository,
	classRepo repositories.ClassRepository,
) (AcademicYearService, MajorService, ClassService) {
	return &academicService{academicYearRepo: academicYearRepo},
		&academicService{majorRepo: majorRepo},
		&academicService{classRepo: classRepo}
}

func (s *academicService) CreateAcademicYear(ctx context.Context, req *requests.CreateAcademicYearRequest) (*entities.AcademicYear, error) {
	tenantID, err := uuid.Parse(req.TenantID)
	if err != nil {
		return nil, err
	}

	ay := &entities.AcademicYear{
		ID:        uuid.New(),
		TenantID:  tenantID,
		Name:      req.Name,
		StartDate: req.StartDate,
		EndDate:   req.EndDate,
		IsActive:  req.IsActive,
		CreatedAt: time.Now(),
	}

	err = s.academicYearRepo.Save(ctx, ay)
	if err != nil {
		return nil, err
	}

	return ay, nil
}

func (s *academicService) CreateMajor(ctx context.Context, req *requests.CreateMajorRequest) (*entities.Major, error) {
	tenantID, err := uuid.Parse(req.TenantID)
	if err != nil {
		return nil, err
	}

	major := &entities.Major{
		ID:        uuid.New(),
		TenantID:  tenantID,
		Name:      req.Name,
		CreatedAt: time.Now(),
	}

	err = s.majorRepo.SaveMajor(ctx, major)
	if err != nil {
		return nil, err
	}

	return major, nil
}

func (s *academicService) CreateClass(ctx context.Context, req *requests.CreateClassRequest) (*entities.Class, error) {
	tenantID, err := uuid.Parse(req.TenantID)
	if err != nil {
		return nil, err
	}
	majorID, err := uuid.Parse(req.MajorID)
	if err != nil {
		return nil, err
	}

	class := &entities.Class{
		ID:         uuid.New(),
		TenantID:   tenantID,
		MajorID:    majorID,
		GradeLevel: req.GradeLevel,
		Name:       req.Name,
		CreatedAt:  time.Now(),
	}

	err = s.classRepo.SaveClass(ctx, class)
	if err != nil {
		return nil, err
	}

	return class, nil
}
