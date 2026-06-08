package domain

import (
	"context"
	"mime/multipart"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/academic/entities"
)

// ==========================================
// REPORT CARD & LEADERBOARD DTOs
// ==========================================

// LeaderboardFilter determines the scope of the ranking
type LeaderboardFilter string

const (
	LeaderboardClass LeaderboardFilter = "class"
	LeaderboardMajor LeaderboardFilter = "major"
	LeaderboardGrade LeaderboardFilter = "grade"
	LeaderboardAll   LeaderboardFilter = "all"
)

type LeaderboardRow struct {
	StudentID   uuid.UUID `json:"student_id"`
	StudentName string    `json:"student_name"`
	NISN        string    `json:"nisn"`
	ClassName   string    `json:"class_name"`
	MajorName   string    `json:"major_name,omitempty"`
	GradeLevel  int       `json:"grade_level"`
	AverageScore float64  `json:"average_score"`
	Rank        int       `json:"rank"`
}

type ReportCardRepository interface {
	// Transactions
	ExecTx(ctx context.Context, fn func(repo ReportCardRepository) error) error

	// Core Report Card DB Ops
	SaveReportCard(ctx context.Context, rc *entities.ReportCard) error
	SaveReportCardGrades(ctx context.Context, grades []*entities.ReportCardGrade) error
	GetReportCardByStudentAndTerm(ctx context.Context, tenantID, studentID, termID uuid.UUID) (*entities.ReportCard, error)

	// Leaderboard DB Ops
	// Calculate and get the ranking dynamically
	GetLeaderboard(ctx context.Context, tenantID uuid.UUID, termID uuid.UUID, filter LeaderboardFilter, filterID *uuid.UUID) ([]*LeaderboardRow, error)

	// Utils
	GetCourseByName(ctx context.Context, tenantID uuid.UUID, courseName string) (*Course, error)
	GetStudentByNISN(ctx context.Context, tenantID uuid.UUID, nisn string) (uuid.UUID, error)
	GetStudentsByClass(ctx context.Context, tenantID, classID uuid.UUID) ([]struct{
		ID uuid.UUID
		Name string
		NISN string
	}, error)
}

type ReportCardUsecase interface {
	// Template Generation
	GenerateExcelTemplate(ctx context.Context, tenantID, classID uuid.UUID) ([]byte, error)

	// Excel Upload & Processing
	UploadExcelGrades(ctx context.Context, tenantID, termID, uploadedBy uuid.UUID, file *multipart.FileHeader) error

	// Leaderboard Retrieval
	GetLeaderboard(ctx context.Context, tenantID uuid.UUID, termID uuid.UUID, filter LeaderboardFilter, filterID string) ([]*LeaderboardRow, error)
}
