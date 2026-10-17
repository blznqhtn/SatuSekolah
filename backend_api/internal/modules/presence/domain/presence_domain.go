package domain

import (
	"context"
	"time"

	"github.com/google/uuid"
)

type AttendanceSummary struct {
	TotalHadir int `json:"total_hadir"`
	TotalSakit int `json:"total_sakit"`
	TotalIzin  int `json:"total_izin"`
	TotalAlpha int `json:"total_alpha"`
}

type WeeklyAttendance struct {
	Date   string `json:"date"`
	Status string `json:"status"` // PRESENT, SICK, EXCUSED, ABSENT, HOLIDAY
}

type ScheduleAttendance struct {
	ID        uuid.UUID  `json:"id"`
	Date      string     `json:"date"` // YYYY-MM-DD
	Day       string     `json:"day"`
	Status    string     `json:"status"`
	Course    string     `json:"course"`
	TimeStart string     `json:"time_start"`
	TimeEnd   string     `json:"time_end"`
	Teacher   string     `json:"teacher"`
	Notes     *string    `json:"notes"`
}

type PresenceRepository interface {
	GetSummary(ctx context.Context, tenantID, studentID uuid.UUID) (*AttendanceSummary, error)
	GetWeekly(ctx context.Context, tenantID, studentID uuid.UUID, startDate, endDate time.Time) ([]*WeeklyAttendance, error)
	GetHistory(ctx context.Context, tenantID, studentID uuid.UUID) ([]*ScheduleAttendance, error)
}

type PresenceUsecase interface {
	GetSummary(ctx context.Context, tenantID, studentID uuid.UUID) (*AttendanceSummary, error)
	GetWeekly(ctx context.Context, tenantID, studentID uuid.UUID, date time.Time) ([]*WeeklyAttendance, error)
	GetHistory(ctx context.Context, tenantID, studentID uuid.UUID) ([]*ScheduleAttendance, error)
}
