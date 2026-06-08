package usecase

import (
	"context"
	"errors"
	"time"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/violations/domain"
)

type violationUsecase struct {
	repo domain.ViolationRepository
}

func NewViolationUsecase(repo domain.ViolationRepository) domain.ViolationUsecase {
	return &violationUsecase{repo: repo}
}

func (u *violationUsecase) CreateViolationType(ctx context.Context, tenantID, staffID uuid.UUID, req *domain.CreateViolationTypeRequest) (*domain.ViolationType, error) {
	vt := &domain.ViolationType{
		ID:              uuid.New().String(),
		TenantID:        &tenantID,
		Name:            req.Name,
		Description:     &req.Description,
		Points:          req.Points,
		AppliesTo:       req.AppliesTo,
		IsActive:        true,
		IsSystemDefault: false,
		CreatedBy:       &staffID,
		CreatedAt:       time.Now(),
	}
	if err := u.repo.CreateViolationType(ctx, vt); err != nil {
		return nil, err
	}
	return vt, nil
}

func (u *violationUsecase) GetViolationTypes(ctx context.Context, tenantID uuid.UUID) ([]*domain.ViolationType, error) {
	return u.repo.GetViolationTypes(ctx, tenantID)
}

func (u *violationUsecase) ToggleViolationType(ctx context.Context, id string, isActive bool) error {
	vt, err := u.repo.GetViolationTypeByID(ctx, id)
	if err != nil {
		return err
	}
	if vt == nil {
		return errors.New("violation type not found")
	}
	return u.repo.ToggleViolationTypeActive(ctx, id, isActive)
}

func (u *violationUsecase) DeleteViolationType(ctx context.Context, id string) error {
	vt, err := u.repo.GetViolationTypeByID(ctx, id)
	if err != nil {
		return err
	}
	if vt == nil {
		return errors.New("violation type not found")
	}
	if vt.IsSystemDefault {
		return errors.New("system default violation types cannot be deleted; you may deactivate them instead")
	}
	return u.repo.DeleteViolationType(ctx, id)
}

// RecordViolation applies a batch of violation types to a user in one operation.
// Staff uploads a photo (evidence_url) and selects multiple violation types.
// All points are summed and each violation type is stored as a separate record.
func (u *violationUsecase) RecordViolation(ctx context.Context, tenantID, staffID uuid.UUID, req *domain.RecordViolationRequest) ([]*domain.UserViolation, error) {
	if len(req.ViolationTypeIDs) == 0 {
		return nil, errors.New("at least one violation type must be selected")
	}
	if req.EvidenceURL == "" {
		return nil, errors.New("evidence_url (photo) is required to record a violation")
	}

	var recorded []*domain.UserViolation

	for _, vtID := range req.ViolationTypeIDs {
		vt, err := u.repo.GetViolationTypeByID(ctx, vtID)
		if err != nil || vt == nil {
			continue // skip invalid types
		}
		if !vt.IsActive {
			continue // skip inactive types
		}

		evidenceURL := req.EvidenceURL
		notes := req.Notes

		uv := &domain.UserViolation{
			TenantID:        tenantID,
			UserID:          req.UserID,
			ViolationTypeID: vtID,
			PointsApplied:   vt.Points,
			EvidenceURL:     &evidenceURL,
			Notes:           &notes,
			RecordedBy:      &staffID,
			ParentNotified:  false, // TODO: integrate with push notification service
		}

		if err := u.repo.CreateUserViolation(ctx, uv); err != nil {
			return nil, err
		}
		recorded = append(recorded, uv)

		// TODO: Send push notification to parent here if user is a student
	}

	return recorded, nil
}

func (u *violationUsecase) GetUserViolationHistory(ctx context.Context, tenantID, userID uuid.UUID) ([]*domain.UserViolation, int, error) {
	violations, err := u.repo.GetUserViolations(ctx, tenantID, userID)
	if err != nil {
		return nil, 0, err
	}
	total, err := u.repo.GetUserTotalPoints(ctx, tenantID, userID)
	if err != nil {
		return nil, 0, err
	}
	return violations, total, nil
}
