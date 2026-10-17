package entities

import (
	"database/sql"
	"time"

	"github.com/google/uuid"
)

type ClassSchedule struct {
	ID         uuid.UUID    `json:"id"`
	TenantID   uuid.UUID    `json:"tenant_id"`
	ClassID    uuid.UUID    `json:"class_id"`
	CourseID   uuid.UUID    `json:"course_id"`
	StaffID  uuid.UUID    `json:"staff_id"`
	DayOfWeek  int          `json:"day_of_week"`
	StartTime  string       `json:"start_time"`
	EndTime    string       `json:"end_time"`
	CreatedAt  time.Time    `json:"created_at"`
	UpdatedAt  sql.NullTime `json:"updated_at"`
}
