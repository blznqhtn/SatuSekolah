package usecase

import (
	"context"
	"errors"
	"time"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/academic/domain"
)

// =============================================================================
// STUDENT PERMIT USECASE
// =============================================================================

type permitUsecase struct {
	repo domain.PermitRepository
}

func NewPermitUsecase(repo domain.PermitRepository) domain.PermitUsecase {
	return &permitUsecase{repo: repo}
}

func (u *permitUsecase) SubmitPermit(ctx context.Context, permit *domain.StudentPermit) error {
	if permit.Reason == "" {
		return errors.New("alasan izin tidak boleh kosong")
	}
	if permit.StartDate.IsZero() || permit.EndDate.IsZero() {
		return errors.New("tanggal izin tidak valid")
	}
	if permit.EndDate.Before(permit.StartDate) {
		return errors.New("tanggal selesai tidak boleh sebelum tanggal mulai")
	}
	permit.Status = domain.PermitPending
	return u.repo.Create(ctx, permit)
}

func (u *permitUsecase) GetMyPermits(ctx context.Context, tenantID, studentID uuid.UUID) ([]*domain.StudentPermit, error) {
	return u.repo.GetByStudent(ctx, tenantID, studentID)
}

func (u *permitUsecase) GetPendingPermits(ctx context.Context, tenantID uuid.UUID) ([]*domain.StudentPermit, error) {
	return u.repo.GetPending(ctx, tenantID)
}

func (u *permitUsecase) ReviewPermit(ctx context.Context, id, reviewerID uuid.UUID, status domain.PermitStatus, note string) error {
	if status != domain.PermitApproved && status != domain.PermitRejected {
		return errors.New("status tidak valid")
	}
	return u.repo.UpdateStatus(ctx, id, status, reviewerID, note)
}

// =============================================================================
// COUNSELING USECASE
// =============================================================================

type counselingUsecase struct {
	repo domain.CounselingRepository
}

func NewCounselingUsecase(repo domain.CounselingRepository) domain.CounselingUsecase {
	return &counselingUsecase{repo: repo}
}

func (u *counselingUsecase) BookSession(ctx context.Context, session *domain.CounselingSession) error {
	if session.Topic == "" {
		return errors.New("topik konseling tidak boleh kosong")
	}
	if session.PreferredDate.IsZero() {
		return errors.New("tanggal konseling tidak valid")
	}
	session.Status = domain.CounselingRequested
	return u.repo.Create(ctx, session)
}

func (u *counselingUsecase) GetMySessions(ctx context.Context, tenantID, studentID uuid.UUID) ([]*domain.CounselingSession, error) {
	return u.repo.GetByStudent(ctx, tenantID, studentID)
}

func (u *counselingUsecase) GetAllSessions(ctx context.Context, tenantID uuid.UUID) ([]*domain.CounselingSession, error) {
	return u.repo.GetAll(ctx, tenantID)
}

func (u *counselingUsecase) ScheduleSession(ctx context.Context, id, counselorID uuid.UUID, scheduledAt time.Time, notes string) error {
	return u.repo.UpdateStatus(ctx, id, domain.CounselingScheduled, counselorID, &scheduledAt, notes)
}

// =============================================================================
// EXTRACURRICULAR USECASE
// =============================================================================

type extracurricularUsecase struct {
	repo domain.ExtracurricularRepository
}

func NewExtracurricularUsecase(repo domain.ExtracurricularRepository) domain.ExtracurricularUsecase {
	return &extracurricularUsecase{repo: repo}
}

func (u *extracurricularUsecase) GetAll(ctx context.Context, tenantID uuid.UUID) ([]*domain.Extracurricular, error) {
	return u.repo.GetAll(ctx, tenantID)
}

func (u *extracurricularUsecase) Create(ctx context.Context, extra *domain.Extracurricular) error {
	if extra.Name == "" {
		return errors.New("nama ekstrakulikuler tidak boleh kosong")
	}
	return u.repo.Create(ctx, extra)
}

func (u *extracurricularUsecase) Register(ctx context.Context, tenantID, studentID, extraID uuid.UUID) error {
	// Cek kuota
	extra, err := u.repo.GetByID(ctx, extraID)
	if err != nil {
		return errors.New("ekstrakulikuler tidak ditemukan")
	}
	if extra.TotalMember >= extra.MaxMembers && extra.MaxMembers > 0 {
		return errors.New("kuota ekstrakulikuler sudah penuh")
	}

	reg := &domain.ExtracurricularRegistration{
		TenantID:          tenantID,
		StudentID:         studentID,
		ExtracurricularID: extraID,
		Status:            domain.RegPending,
	}
	return u.repo.Register(ctx, reg)
}

func (u *extracurricularUsecase) GetMyRegistrations(ctx context.Context, tenantID, studentID uuid.UUID) ([]*domain.ExtracurricularRegistration, error) {
	return u.repo.GetMyRegistrations(ctx, tenantID, studentID)
}

func (u *extracurricularUsecase) ApproveRegistration(ctx context.Context, regID uuid.UUID) error {
	return u.repo.UpdateRegistrationStatus(ctx, regID, domain.RegApproved)
}

func (u *extracurricularUsecase) RejectRegistration(ctx context.Context, regID uuid.UUID) error {
	return u.repo.UpdateRegistrationStatus(ctx, regID, domain.RegRejected)
}
