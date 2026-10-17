package usecase

import (
	"context"
	"time"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/calendar/domain"
)

type calendarUsecase struct {
	repo domain.CalendarRepository
}

func NewCalendarUsecase(repo domain.CalendarRepository) domain.CalendarUsecase {
	return &calendarUsecase{repo: repo}
}

func (uc *calendarUsecase) GetEventsByMonth(ctx context.Context, tenantID uuid.UUID, year, month int, targetUserID *uuid.UUID) ([]*domain.CalendarEvent, error) {
	return uc.repo.GetEventsByMonth(ctx, tenantID, year, month, targetUserID)
}

func (uc *calendarUsecase) GetEventByID(ctx context.Context, tenantID, eventID uuid.UUID) (*domain.CalendarEvent, error) {
	return uc.repo.GetEventByID(ctx, tenantID, eventID)
}

func (uc *calendarUsecase) CreateEvent(ctx context.Context, req *domain.CalendarEvent) (*domain.CalendarEvent, error) {
	req.ID = uuid.New()
	req.CreatedAt = time.Now()
	req.UpdatedAt = time.Now()

	if req.Status == "" {
		req.Status = "ACTIVE"
	}

	if err := uc.repo.CreateEvent(ctx, req); err != nil {
		return nil, err
	}
	return req, nil
}

func (uc *calendarUsecase) UpdateEvent(ctx context.Context, req *domain.CalendarEvent) (*domain.CalendarEvent, error) {
	req.UpdatedAt = time.Now()
	if err := uc.repo.UpdateEvent(ctx, req); err != nil {
		return nil, err
	}
	return uc.repo.GetEventByID(ctx, req.TenantID, req.ID)
}

func (uc *calendarUsecase) DeleteEvent(ctx context.Context, tenantID, eventID uuid.UUID) error {
	return uc.repo.DeleteEvent(ctx, tenantID, eventID)
}
