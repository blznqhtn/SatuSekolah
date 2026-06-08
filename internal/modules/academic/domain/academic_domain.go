package domain

import (
	"context"
	"time"

	"github.com/google/uuid"
)

// ==========================================
// LMS DOMAIN: Courses, Modules, Submissions
// ==========================================

type Course struct {
	ID        uuid.UUID `json:"id"`
	TenantID  uuid.UUID `json:"tenant_id"`
	Name      string    `json:"name"`
	StaffID uuid.UUID `json:"staff_id"`
	CreatedAt time.Time `json:"created_at"`
	DeletedAt *time.Time `json:"deleted_at,omitempty"`
}

type CourseModule struct {
	ID        uuid.UUID `json:"id"`
	CourseID  uuid.UUID `json:"course_id"`
	Title     string    `json:"title"`
	Content   string    `json:"content"`
	CreatedAt time.Time `json:"created_at"`
	DeletedAt *time.Time `json:"deleted_at,omitempty"`
}

type Submission struct {
	ID         uuid.UUID  `json:"id"`
	ModuleID   uuid.UUID  `json:"module_id"`
	StudentID  uuid.UUID  `json:"student_id"`
	FileURL    string     `json:"file_url"`
	Notes      string     `json:"notes"`
	Score      *float64   `json:"score,omitempty"`
	GradedBy   *uuid.UUID `json:"graded_by,omitempty"`
	GradedAt   *time.Time `json:"graded_at,omitempty"`
	SubmittedAt time.Time `json:"submitted_at"`
}

// ==========================================
// ASSIGNMENT TARGETS (Universal Targeting)
// ==========================================

type SourceType string
type TargetType string

const (
	SourceCourse SourceType = "COURSE"
	SourceQuiz   SourceType = "QUIZ"
)

const (
	TargetClass TargetType = "CLASS"
	TargetMajor TargetType = "MAJOR"
	TargetRole  TargetType = "ROLE"
	TargetUser  TargetType = "USER"
)

type AssignmentTarget struct {
	ID         uuid.UUID  `json:"id"`
	SourceType SourceType `json:"source_type"`
	SourceID   uuid.UUID  `json:"source_id"`
	TargetType TargetType `json:"target_type"`
	TargetID   uuid.UUID  `json:"target_id"`
	CreatedAt  time.Time  `json:"created_at"`
}

type AcademicRepository interface {
	ExecTx(ctx context.Context, fn func(repo AcademicRepository) error) error

	// Courses
	CreateCourse(ctx context.Context, course *Course) error
	GetCourses(ctx context.Context, tenantID uuid.UUID) ([]*Course, error)

	// Modules
	CreateModule(ctx context.Context, module *CourseModule) error
	GetModulesByCourse(ctx context.Context, courseID uuid.UUID) ([]*CourseModule, error)

	// Submissions
	CreateSubmission(ctx context.Context, sub *Submission) error
	GetSubmissionsByModule(ctx context.Context, moduleID uuid.UUID) ([]*Submission, error)
	GradeSubmission(ctx context.Context, submissionID uuid.UUID, score float64, gradedBy uuid.UUID) error

	// Assignment Targets
	CreateAssignmentTarget(ctx context.Context, target *AssignmentTarget) error
	GetTargetsForSource(ctx context.Context, sourceType SourceType, sourceID uuid.UUID) ([]*AssignmentTarget, error)
}

type AcademicUsecase interface {
	CreateCourse(ctx context.Context, course *Course) error
	GetCourses(ctx context.Context, tenantID uuid.UUID) ([]*Course, error)

	CreateModule(ctx context.Context, module *CourseModule) error
	GetModulesByCourse(ctx context.Context, courseID uuid.UUID) ([]*CourseModule, error)

	SubmitWork(ctx context.Context, sub *Submission) error
	GetSubmissionsByModule(ctx context.Context, moduleID uuid.UUID) ([]*Submission, error)
	GradeSubmission(ctx context.Context, submissionID uuid.UUID, score float64, gradedBy uuid.UUID) error

	AssignTarget(ctx context.Context, target *AssignmentTarget) error
	GetTargetsForSource(ctx context.Context, sourceType SourceType, sourceID uuid.UUID) ([]*AssignmentTarget, error)
}
