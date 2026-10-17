package domain

import (
	"context"
	"time"

	"github.com/google/uuid"
)

// ==========================================
// CBA DOMAIN: Exam Mode (UTBK-Style CBT)
// ==========================================

type QuestionType string

const (
	QuestionMultipleChoice QuestionType = "MULTIPLE_CHOICE"
	QuestionMultipleSelect QuestionType = "MULTIPLE_SELECT"
	QuestionEssay          QuestionType = "ESSAY"
	QuestionMatching       QuestionType = "MATCHING"
)

type MediaType string

const (
	MediaNone     MediaType = "NONE"
	MediaImage    MediaType = "IMAGE"
	MediaAudio    MediaType = "AUDIO"
	MediaVideo    MediaType = "VIDEO"
	MediaDocument MediaType = "DOCUMENT"
)

type SessionStatus string

const (
	SessionWaiting   SessionStatus = "WAITING"
	SessionOngoing   SessionStatus = "ONGOING"
	SessionSubmitted SessionStatus = "SUBMITTED"
)

// ---- LMS Quiz (lightweight, embedded in LMS module) ----

type Quiz struct {
	ID        uuid.UUID  `json:"id"`
	ModuleID  uuid.UUID  `json:"module_id"`
	Title     string     `json:"title"`
	DeletedAt *time.Time `json:"deleted_at,omitempty"`
	Questions []Question `json:"questions,omitempty"`
}

type Question struct {
	ID                uuid.UUID        `json:"id"`
	QuizID            uuid.UUID        `json:"quiz_id"`
	Type              QuestionType     `json:"type"`
	QuestionText      string           `json:"question_text"`
	MediaURL          string           `json:"media_url,omitempty"`
	MediaType         MediaType        `json:"media_type"`
	AIReferenceAnswer string           `json:"ai_reference_answer,omitempty"`
	DeletedAt         *time.Time       `json:"deleted_at,omitempty"`
	Options           []QuestionOption `json:"options,omitempty"`
}

type QuestionOption struct {
	ID         uuid.UUID `json:"id"`
	QuestionID uuid.UUID `json:"question_id"`
	OptionText string    `json:"option_text,omitempty"`
	MediaURL   string    `json:"media_url,omitempty"`
	MediaType  MediaType `json:"media_type"`
	IsCorrect  bool      `json:"is_correct"`
	MatchLeft  string    `json:"match_left,omitempty"`
	MatchRight string    `json:"match_right,omitempty"`
	CreatedAt  time.Time `json:"created_at"`
}

type StudentAnswer struct {
	ID         uuid.UUID `json:"id"`
	QuestionID uuid.UUID `json:"question_id"`
	StudentID  uuid.UUID `json:"student_id"`
	AnswerText string    `json:"answer_text"`
	IsCorrect  *bool     `json:"is_correct,omitempty"`
	AIScore    *float64  `json:"ai_score,omitempty"`
	AIFeedback string    `json:"ai_feedback,omitempty"`
	CreatedAt  time.Time `json:"created_at"`
}

// ---- CBA Exam Mode (UTBK-style) ----

type CBAFolder struct {
	ID              uuid.UUID  `json:"id"`
	TenantID        uuid.UUID  `json:"tenant_id"`
	Name            string     `json:"name"`
	Description     string     `json:"description,omitempty"`
	CurrentToken    string     `json:"current_token"`
	TokenExpiresAt  time.Time  `json:"token_expires_at"`
	CreatedBy       uuid.UUID  `json:"created_by"`
	CreatedAt       time.Time  `json:"created_at"`
	UpdatedAt       time.Time  `json:"updated_at"`
	DeletedAt       *time.Time `json:"deleted_at,omitempty"`
}

type CBAExam struct {
	ID                     uuid.UUID  `json:"id"`
	FolderID               uuid.UUID  `json:"folder_id"`
	TenantID               uuid.UUID  `json:"tenant_id"`
	Title                  string     `json:"title"`
	TermsAndConditions     string     `json:"terms_and_conditions,omitempty"`
	StartTime              time.Time  `json:"start_time"`
	EndTime                time.Time  `json:"end_time"`
	WaitingRoomOpenMinutes int        `json:"waiting_room_open_minutes"`
	ShowResults            bool       `json:"show_results"`
	CreatedBy              uuid.UUID  `json:"created_by"`
	CreatedAt              time.Time  `json:"created_at"`
	UpdatedAt              time.Time  `json:"updated_at"`
	DeletedAt              *time.Time `json:"deleted_at,omitempty"`

	// Computed fields (server-time based), not stored:
	Status         string `json:"status,omitempty"` // NOT_STARTED, WAITING_ROOM, ONGOING, ENDED
	QuestionCount  int    `json:"question_count,omitempty"`
}

type CBAQuestion struct {
	ID                uuid.UUID    `json:"id"`
	ExamID            uuid.UUID    `json:"exam_id"`
	OrderIndex        int          `json:"order_index"`
	QuestionType      QuestionType `json:"question_type"`
	QuestionText      string       `json:"question_text"`
	MediaURL          string       `json:"media_url,omitempty"`
	MediaType         MediaType    `json:"media_type"`
	ScoreWeight       float64      `json:"score_weight"`
	AIReferenceAnswer string       `json:"ai_reference_answer,omitempty"`
	CreatedAt         time.Time    `json:"created_at"`
	Options           []CBAOption  `json:"options,omitempty"`

	// Per-student state, populated at query time:
	StudentOptionID *uuid.UUID `json:"student_option_id,omitempty"`
	StudentEssay    string     `json:"student_essay,omitempty"`
	IsDoubt         bool       `json:"is_doubt,omitempty"`
	IsAnswered      bool       `json:"is_answered,omitempty"`
}

type CBAOption struct {
	ID         uuid.UUID `json:"id"`
	QuestionID uuid.UUID `json:"question_id"`
	OptionText string    `json:"option_text,omitempty"`
	MediaURL   string    `json:"media_url,omitempty"`
	MediaType  MediaType `json:"media_type"`
	// is_correct is hidden from students during exam
	IsCorrect *bool     `json:"is_correct,omitempty"` // nil = hidden
	CreatedAt time.Time `json:"created_at"`
}

type CBASession struct {
	ID                  uuid.UUID     `json:"id"`
	ExamID              uuid.UUID     `json:"exam_id"`
	StudentID           uuid.UUID     `json:"student_id"`
	WaitingRoomJoinedAt *time.Time    `json:"waiting_room_joined_at,omitempty"`
	StartedAt           *time.Time    `json:"started_at,omitempty"`
	SubmittedAt         *time.Time    `json:"submitted_at,omitempty"`
	IsAutoSubmitted     bool          `json:"is_auto_submitted"`
	FinalScore          *float64      `json:"final_score,omitempty"`
	Status              SessionStatus `json:"status"`
	CreatedAt           time.Time     `json:"created_at"`
}

type CBAAnswer struct {
	ID         uuid.UUID  `json:"id"`
	SessionID  uuid.UUID  `json:"session_id"`
	QuestionID uuid.UUID  `json:"question_id"`
	OptionID   *uuid.UUID `json:"option_id,omitempty"`
	EssayText  string     `json:"essay_text,omitempty"`
	IsDoubt    bool       `json:"is_doubt"`
	AnsweredAt time.Time  `json:"answered_at"`
}

// StudentProfile contains identity data shown in the left panel during an exam
type StudentExamProfile struct {
	StudentID  uuid.UUID `json:"student_id"`
	Name       string    `json:"name"`
	NISN       string    `json:"nisn"`
	PhotoURL   string    `json:"photo_url,omitempty"`
	MajorName  string    `json:"major_name,omitempty"`
	ClassName  string    `json:"class_name,omitempty"`
}

// ==========================================
// REPOSITORY INTERFACES
// ==========================================

type CBARepository interface {
	ExecTx(ctx context.Context, fn func(repo CBARepository) error) error

	// LMS Quizzes (lightweight)
	CreateQuiz(ctx context.Context, quiz *Quiz) error
	GetQuizzesByModule(ctx context.Context, moduleID uuid.UUID) ([]*Quiz, error)
	GetQuizByID(ctx context.Context, quizID uuid.UUID) (*Quiz, error)
	CreateQuestion(ctx context.Context, q *Question) error
	GetQuestionsByQuiz(ctx context.Context, quizID uuid.UUID) ([]*Question, error)
	CreateOption(ctx context.Context, opt *QuestionOption) error
	GetOptionsByQuestion(ctx context.Context, questionID uuid.UUID) ([]*QuestionOption, error)
	CreateAnswer(ctx context.Context, answer *StudentAnswer) error
	GetAnswersByQuizAndStudent(ctx context.Context, quizID, studentID uuid.UUID) ([]*StudentAnswer, error)

	// CBA Folders
	CreateFolder(ctx context.Context, folder *CBAFolder) error
	GetFoldersByTenant(ctx context.Context, tenantID uuid.UUID) ([]*CBAFolder, error)
	GetFolderByID(ctx context.Context, folderID uuid.UUID) (*CBAFolder, error)
	UpdateFolderToken(ctx context.Context, folderID uuid.UUID, token string, expiresAt time.Time) error

	// CBA Exams
	CreateExam(ctx context.Context, exam *CBAExam) error
	GetExamsByFolderToday(ctx context.Context, folderID uuid.UUID) ([]*CBAExam, error)
	GetExamByID(ctx context.Context, examID uuid.UUID) (*CBAExam, error)
	CountQuestions(ctx context.Context, examID uuid.UUID) (int, error)

	// CBA Questions & Options
	CreateCBAQuestion(ctx context.Context, q *CBAQuestion) error
	GetCBAQuestionsByExam(ctx context.Context, examID uuid.UUID) ([]*CBAQuestion, error)
	CreateCBAOption(ctx context.Context, opt *CBAOption) error
	GetCBAOptionsByQuestion(ctx context.Context, questionID uuid.UUID) ([]*CBAOption, error)

	// CBA Sessions
	CreateOrGetSession(ctx context.Context, examID, studentID uuid.UUID) (*CBASession, error)
	UpdateSessionStatus(ctx context.Context, sessionID uuid.UUID, status SessionStatus, startedAt *time.Time) error
	SubmitSession(ctx context.Context, sessionID uuid.UUID, score float64, isAuto bool) error
	GetSession(ctx context.Context, examID, studentID uuid.UUID) (*CBASession, error)
	GetExpiredOngoingSessions(ctx context.Context) ([]*CBASession, error)

	// CBA Answers
	UpsertAnswer(ctx context.Context, answer *CBAAnswer) error
	GetAnswersBySession(ctx context.Context, sessionID uuid.UUID) ([]*CBAAnswer, error)
	CheckOptionCorrect(ctx context.Context, optionID uuid.UUID) (bool, error)

	// Student profile (for identity panel)
	GetStudentProfile(ctx context.Context, studentID uuid.UUID) (*StudentExamProfile, error)
}

// ==========================================
// USECASE INTERFACES
// ==========================================

type CBAUsecase interface {
	// LMS Quizzes (lightweight)
	CreateQuiz(ctx context.Context, quiz *Quiz) error
	GetQuizzesByModule(ctx context.Context, moduleID uuid.UUID) ([]*Quiz, error)
	GetQuizByID(ctx context.Context, quizID uuid.UUID) (*Quiz, error)
	AddQuestion(ctx context.Context, q *Question) error
	AddOption(ctx context.Context, opt *QuestionOption) error
	SubmitAnswer(ctx context.Context, answer *StudentAnswer) error
	GetStudentAnswers(ctx context.Context, quizID, studentID uuid.UUID) ([]*StudentAnswer, error)

	// CBA Exam Mode
	GetServerTime(ctx context.Context) time.Time

	// Folder management (MANAGE_CBA permission required)
	CreateFolder(ctx context.Context, tenantID, createdBy uuid.UUID, name, description string) (*CBAFolder, error)
	GetFolders(ctx context.Context, tenantID uuid.UUID) ([]*CBAFolder, error)
	RefreshFolderToken(ctx context.Context, folderID uuid.UUID) (*CBAFolder, error)
	VerifyFolderToken(ctx context.Context, folderID uuid.UUID, token string) error

	// Exam management (MANAGE_CBA permission required)
	CreateExam(ctx context.Context, exam *CBAExam) (*CBAExam, error)
	GetTodayExams(ctx context.Context, folderID uuid.UUID) ([]*CBAExam, error)

	// Question & option management
	AddCBAQuestion(ctx context.Context, q *CBAQuestion) (*CBAQuestion, error)
	AddCBAOption(ctx context.Context, opt *CBAOption) (*CBAOption, error)

	// Student exam flow
	JoinWaitingRoom(ctx context.Context, examID, studentID uuid.UUID) (*CBASession, *CBAExam, error)
	StartExam(ctx context.Context, examID, studentID uuid.UUID) (*CBASession, error)
	GetExamQuestions(ctx context.Context, examID, studentID uuid.UUID) ([]*CBAQuestion, *StudentExamProfile, error)
	SaveAnswer(ctx context.Context, sessionID, questionID uuid.UUID, optionID *uuid.UUID, essayText string, isDoubt bool, studentID uuid.UUID) error
	SubmitExam(ctx context.Context, examID, studentID uuid.UUID) (*CBASession, error)

	// Background auto-submit
	AutoSubmitExpiredSessions(ctx context.Context) error
}
