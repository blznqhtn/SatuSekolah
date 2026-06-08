package usecase

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"errors"
	"strings"
	"time"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/cba/domain"
)

type cbaUsecase struct {
	repo domain.CBARepository
}

func NewCBAUsecase(repo domain.CBARepository) domain.CBAUsecase {
	return &cbaUsecase{repo: repo}
}

// ==========================================
// UTILITY
// ==========================================

func generateToken() (string, error) {
	b := make([]byte, 3) // 3 bytes = 6 hex chars
	_, err := rand.Read(b)
	if err != nil {
		return "", err
	}
	return strings.ToUpper(hex.EncodeToString(b)), nil
}

// GetServerTime returns the authoritative server time.
func (uc *cbaUsecase) GetServerTime(ctx context.Context) time.Time {
	return time.Now().UTC()
}

// computeExamStatus resolves display status based on server time.
func computeExamStatus(exam *domain.CBAExam) string {
	now := time.Now().UTC()
	waitingRoomOpen := exam.StartTime.Add(-time.Duration(exam.WaitingRoomOpenMinutes) * time.Minute)
	switch {
	case now.After(exam.EndTime):
		return "ENDED"
	case now.After(exam.StartTime):
		return "ONGOING"
	case now.After(waitingRoomOpen):
		return "WAITING_ROOM"
	default:
		return "NOT_STARTED"
	}
}

// ==========================================
// LMS QUIZ (Lightweight)
// ==========================================

func (uc *cbaUsecase) CreateQuiz(ctx context.Context, quiz *domain.Quiz) error {
	return uc.repo.CreateQuiz(ctx, quiz)
}

func (uc *cbaUsecase) GetQuizzesByModule(ctx context.Context, moduleID uuid.UUID) ([]*domain.Quiz, error) {
	return uc.repo.GetQuizzesByModule(ctx, moduleID)
}

func (uc *cbaUsecase) GetQuizByID(ctx context.Context, quizID uuid.UUID) (*domain.Quiz, error) {
	return uc.repo.GetQuizByID(ctx, quizID)
}

func (uc *cbaUsecase) AddQuestion(ctx context.Context, q *domain.Question) error {
	return uc.repo.CreateQuestion(ctx, q)
}

func (uc *cbaUsecase) AddOption(ctx context.Context, opt *domain.QuestionOption) error {
	return uc.repo.CreateOption(ctx, opt)
}

func (uc *cbaUsecase) SubmitAnswer(ctx context.Context, answer *domain.StudentAnswer) error {
	return uc.repo.CreateAnswer(ctx, answer)
}

func (uc *cbaUsecase) GetStudentAnswers(ctx context.Context, quizID, studentID uuid.UUID) ([]*domain.StudentAnswer, error) {
	return uc.repo.GetAnswersByQuizAndStudent(ctx, quizID, studentID)
}

// ==========================================
// CBA FOLDER MANAGEMENT
// ==========================================

func (uc *cbaUsecase) CreateFolder(ctx context.Context, tenantID, createdBy uuid.UUID, name, description string) (*domain.CBAFolder, error) {
	token, err := generateToken()
	if err != nil {
		return nil, err
	}
	folder := &domain.CBAFolder{
		TenantID:       tenantID,
		Name:           name,
		Description:    description,
		CurrentToken:   token,
		TokenExpiresAt: time.Now().UTC().Add(5 * time.Minute),
		CreatedBy:      createdBy,
	}
	if err := uc.repo.CreateFolder(ctx, folder); err != nil {
		return nil, err
	}
	return folder, nil
}

func (uc *cbaUsecase) GetFolders(ctx context.Context, tenantID uuid.UUID) ([]*domain.CBAFolder, error) {
	return uc.repo.GetFoldersByTenant(ctx, tenantID)
}

// RefreshFolderToken generates a new token valid for 5 minutes.
func (uc *cbaUsecase) RefreshFolderToken(ctx context.Context, folderID uuid.UUID) (*domain.CBAFolder, error) {
	folder, err := uc.repo.GetFolderByID(ctx, folderID)
	if err != nil {
		return nil, err
	}
	if folder == nil {
		return nil, errors.New("folder not found")
	}
	token, err := generateToken()
	if err != nil {
		return nil, err
	}
	expiresAt := time.Now().UTC().Add(5 * time.Minute)
	if err := uc.repo.UpdateFolderToken(ctx, folderID, token, expiresAt); err != nil {
		return nil, err
	}
	folder.CurrentToken = token
	folder.TokenExpiresAt = expiresAt
	return folder, nil
}

// VerifyFolderToken validates a student's submitted token against the current active token.
func (uc *cbaUsecase) VerifyFolderToken(ctx context.Context, folderID uuid.UUID, token string) error {
	folder, err := uc.repo.GetFolderByID(ctx, folderID)
	if err != nil {
		return err
	}
	if folder == nil {
		return errors.New("folder not found")
	}
	// Check token match (case-insensitive)
	if !strings.EqualFold(folder.CurrentToken, token) {
		return errors.New("invalid token")
	}
	// Token must not be expired
	if time.Now().UTC().After(folder.TokenExpiresAt) {
		return errors.New("token has expired, please ask for the latest token")
	}
	return nil
}

// ==========================================
// CBA EXAM MANAGEMENT
// ==========================================

func (uc *cbaUsecase) CreateExam(ctx context.Context, exam *domain.CBAExam) (*domain.CBAExam, error) {
	if exam.EndTime.Before(exam.StartTime) {
		return nil, errors.New("end_time must be after start_time")
	}
	if err := uc.repo.CreateExam(ctx, exam); err != nil {
		return nil, err
	}
	exam.Status = computeExamStatus(exam)
	return exam, nil
}

func (uc *cbaUsecase) GetTodayExams(ctx context.Context, folderID uuid.UUID) ([]*domain.CBAExam, error) {
	exams, err := uc.repo.GetExamsByFolderToday(ctx, folderID)
	if err != nil {
		return nil, err
	}
	for _, e := range exams {
		e.Status = computeExamStatus(e)
		count, _ := uc.repo.CountQuestions(ctx, e.ID)
		e.QuestionCount = count
	}
	return exams, nil
}

func (uc *cbaUsecase) AddCBAQuestion(ctx context.Context, q *domain.CBAQuestion) (*domain.CBAQuestion, error) {
	if err := uc.repo.CreateCBAQuestion(ctx, q); err != nil {
		return nil, err
	}
	return q, nil
}

func (uc *cbaUsecase) AddCBAOption(ctx context.Context, opt *domain.CBAOption) (*domain.CBAOption, error) {
	if err := uc.repo.CreateCBAOption(ctx, opt); err != nil {
		return nil, err
	}
	return opt, nil
}

// ==========================================
// STUDENT EXAM FLOW
// ==========================================

// JoinWaitingRoom: student enters before exam starts (within waiting_room_open_minutes window).
func (uc *cbaUsecase) JoinWaitingRoom(ctx context.Context, examID, studentID uuid.UUID) (*domain.CBASession, *domain.CBAExam, error) {
	exam, err := uc.repo.GetExamByID(ctx, examID)
	if err != nil {
		return nil, nil, err
	}
	if exam == nil {
		return nil, nil, errors.New("exam not found")
	}
	status := computeExamStatus(exam)
	if status == "NOT_STARTED" {
		return nil, nil, errors.New("waiting room is not open yet")
	}
	if status == "ENDED" {
		return nil, nil, errors.New("this exam has already ended")
	}

	session, err := uc.repo.CreateOrGetSession(ctx, examID, studentID)
	if err != nil {
		return nil, nil, err
	}
	if session.Status == domain.SessionSubmitted {
		return nil, nil, errors.New("you have already submitted this exam")
	}

	exam.Status = status
	return session, exam, nil
}

// StartExam: starts the session. Only allowed when server time >= start_time.
func (uc *cbaUsecase) StartExam(ctx context.Context, examID, studentID uuid.UUID) (*domain.CBASession, error) {
	exam, err := uc.repo.GetExamByID(ctx, examID)
	if err != nil {
		return nil, err
	}
	if exam == nil {
		return nil, errors.New("exam not found")
	}
	now := time.Now().UTC()
	if now.Before(exam.StartTime) {
		return nil, errors.New("exam has not started yet — please wait for the countdown")
	}
	if now.After(exam.EndTime) {
		return nil, errors.New("this exam has already ended")
	}

	session, err := uc.repo.GetSession(ctx, examID, studentID)
	if err != nil {
		return nil, err
	}
	if session == nil {
		return nil, errors.New("please join the waiting room first")
	}
	if session.Status == domain.SessionSubmitted {
		return nil, errors.New("you have already submitted this exam")
	}
	if session.Status == domain.SessionOngoing {
		return session, nil // idempotent
	}

	if err := uc.repo.UpdateSessionStatus(ctx, session.ID, domain.SessionOngoing, &now); err != nil {
		return nil, err
	}
	session.Status = domain.SessionOngoing
	session.StartedAt = &now
	return session, nil
}

// GetExamQuestions: returns the full question list with current student's answer state.
func (uc *cbaUsecase) GetExamQuestions(ctx context.Context, examID, studentID uuid.UUID) ([]*domain.CBAQuestion, *domain.StudentExamProfile, error) {
	session, err := uc.repo.GetSession(ctx, examID, studentID)
	if err != nil {
		return nil, nil, err
	}
	if session == nil || session.Status == domain.SessionWaiting {
		return nil, nil, errors.New("exam not started")
	}

	// Auto-submit check: if exam is past end_time but session not submitted, force submit
	exam, err := uc.repo.GetExamByID(ctx, examID)
	if err != nil {
		return nil, nil, err
	}
	if time.Now().UTC().After(exam.EndTime) && session.Status == domain.SessionOngoing {
		score, _ := uc.calculateScore(ctx, session.ID, examID)
		_ = uc.repo.SubmitSession(ctx, session.ID, score, true)
		return nil, nil, errors.New("exam time has expired — your answers have been automatically submitted")
	}

	questions, err := uc.repo.GetCBAQuestionsByExam(ctx, examID)
	if err != nil {
		return nil, nil, err
	}

	// Attach options (without is_correct)
	answers, _ := uc.repo.GetAnswersBySession(ctx, session.ID)
	answerMap := make(map[uuid.UUID]*domain.CBAAnswer)
	for _, a := range answers {
		answerMap[a.QuestionID] = a
	}

	for _, q := range questions {
		ptrOpts, _ := uc.repo.GetCBAOptionsByQuestion(ctx, q.ID)
		// Convert to value slice and hide is_correct from student
		opts := make([]domain.CBAOption, 0, len(ptrOpts))
		for _, o := range ptrOpts {
			o.IsCorrect = nil // hide answer from student
			opts = append(opts, *o)
		}
		q.Options = opts

		// Attach student's current answer state
		if ans, ok := answerMap[q.ID]; ok {
			q.StudentOptionID = ans.OptionID
			q.StudentEssay = ans.EssayText
			q.IsDoubt = ans.IsDoubt
			q.IsAnswered = ans.OptionID != nil || ans.EssayText != ""
		}
	}

	profile, _ := uc.repo.GetStudentProfile(ctx, studentID)
	return questions, profile, nil
}

// SaveAnswer: upserts one answer. Validates session belongs to student.
func (uc *cbaUsecase) SaveAnswer(ctx context.Context, sessionID, questionID uuid.UUID, optionID *uuid.UUID, essayText string, isDoubt bool, studentID uuid.UUID) error {
	answer := &domain.CBAAnswer{
		SessionID:  sessionID,
		QuestionID: questionID,
		OptionID:   optionID,
		EssayText:  essayText,
		IsDoubt:    isDoubt,
	}
	return uc.repo.UpsertAnswer(ctx, answer)
}

// SubmitExam: manually submits the exam, calculates score.
func (uc *cbaUsecase) SubmitExam(ctx context.Context, examID, studentID uuid.UUID) (*domain.CBASession, error) {
	exam, err := uc.repo.GetExamByID(ctx, examID)
	if err != nil {
		return nil, err
	}
	if exam == nil {
		return nil, errors.New("exam not found")
	}

	session, err := uc.repo.GetSession(ctx, examID, studentID)
	if err != nil {
		return nil, err
	}
	if session == nil {
		return nil, errors.New("no active session found")
	}
	if session.Status == domain.SessionSubmitted {
		return session, nil // idempotent
	}

	score, err := uc.calculateScore(ctx, session.ID, examID)
	if err != nil {
		return nil, err
	}

	if err := uc.repo.SubmitSession(ctx, session.ID, score, false); err != nil {
		return nil, err
	}

	session.Status = domain.SessionSubmitted
	if !exam.ShowResults {
		// Hide score if configured
		return session, nil
	}
	session.FinalScore = &score
	return session, nil
}

// calculateScore: tallies correct multiple choice answers.
func (uc *cbaUsecase) calculateScore(ctx context.Context, sessionID, examID uuid.UUID) (float64, error) {
	answers, err := uc.repo.GetAnswersBySession(ctx, sessionID)
	if err != nil {
		return 0, err
	}
	questions, err := uc.repo.GetCBAQuestionsByExam(ctx, examID)
	if err != nil {
		return 0, err
	}

	totalWeight := 0.0
	earnedScore := 0.0

	for _, q := range questions {
		totalWeight += q.ScoreWeight
		if q.QuestionType == domain.QuestionEssay {
			continue // Essay graded separately (or by AI)
		}
		for _, ans := range answers {
			if ans.QuestionID != q.ID || ans.OptionID == nil {
				continue
			}
			isCorrect, err := uc.repo.CheckOptionCorrect(ctx, *ans.OptionID)
			if err == nil && isCorrect {
				earnedScore += q.ScoreWeight
			}
		}
	}

	if totalWeight == 0 {
		return 0, nil
	}
	return (earnedScore / totalWeight) * 100, nil
}

// AutoSubmitExpiredSessions: called by a background goroutine/cron.
func (uc *cbaUsecase) AutoSubmitExpiredSessions(ctx context.Context) error {
	sessions, err := uc.repo.GetExpiredOngoingSessions(ctx)
	if err != nil {
		return err
	}
	for _, s := range sessions {
		score, _ := uc.calculateScore(ctx, s.ID, s.ExamID)
		_ = uc.repo.SubmitSession(ctx, s.ID, score, true)
	}
	return nil
}
