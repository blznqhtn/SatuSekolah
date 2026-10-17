package domain

import (
	"context"
	"time"

	"github.com/google/uuid"
)

type DashboardSummary struct {
	Student             *StudentInfo `json:"student"`
	AttendancePercent   float64      `json:"attendance_percentage"`
	AverageScore        float64      `json:"average_score"`
	TotalViolationPoints int         `json:"total_violation_points"`
}

type StudentInfo struct {
	ID        uuid.UUID `json:"id"`
	Name      string    `json:"name"`
	ClassName string    `json:"class_name"`
	Major     string    `json:"major"`
	School    string    `json:"school"`
}

type ActivityLog struct {
	ID         uuid.UUID `json:"id"`
	TenantID   uuid.UUID `json:"tenant_id"`
	UserID     uuid.UUID `json:"user_id"`
	Type       string    `json:"type"`
	Title      string    `json:"title"`
	Subtitle   string    `json:"subtitle"`
	TimeLabel  string    `json:"time_label"`
	Emoji      string    `json:"emoji"`
	BadgeColor string    `json:"badge_color"`
	BadgeLabel string    `json:"badge_label"`
	CreatedAt  time.Time `json:"created_at"`
}

type DashboardRepository interface {
	GetStudentInfo(ctx context.Context, tenantID, studentID uuid.UUID) (*StudentInfo, error)
	GetAttendancePercentage(ctx context.Context, tenantID, studentID uuid.UUID) (float64, error)
	GetAverageScore(ctx context.Context, tenantID, studentID uuid.UUID) (float64, error)
	GetTotalViolationPoints(ctx context.Context, tenantID, studentID uuid.UUID) (int, error)
	GetActivities(ctx context.Context, tenantID, studentID uuid.UUID, limit int) ([]*ActivityLog, error)
}

type DashboardUsecase interface {
	GetSummary(ctx context.Context, tenantID, studentID uuid.UUID) (*DashboardSummary, error)
	GetActivities(ctx context.Context, tenantID, studentID uuid.UUID) ([]*ActivityLog, error)
}
