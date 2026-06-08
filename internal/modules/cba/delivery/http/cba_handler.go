package http

import (
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/middleware"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/cba/domain"
)

type CBAHandler struct {
	uc domain.CBAUsecase
}

func NewCBAHandler(uc domain.CBAUsecase) *CBAHandler {
	return &CBAHandler{uc: uc}
}

// ==========================================
// SERVER TIME
// ==========================================

// GET /api/v1/cba/time — Returns authoritative server time (UTC)
func (h *CBAHandler) GetServerTime(c *fiber.Ctx) error {
	t := h.uc.GetServerTime(c.Context())
	return c.JSON(fiber.Map{
		"server_time": t.Format("2006-01-02T15:04:05Z"),
		"unix":        t.Unix(),
	})
}

// ==========================================
// FOLDER MANAGEMENT (MANAGE_CBA permission)
// ==========================================

// POST /api/v1/cba/folders — Create a new exam folder
func (h *CBAHandler) CreateFolder(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)
	createdBy, _ := uuid.Parse(claims.UserID)

	var body struct {
		Name        string `json:"name"`
		Description string `json:"description"`
	}
	if err := c.BodyParser(&body); err != nil || body.Name == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "name is required"})
	}

	folder, err := h.uc.CreateFolder(c.Context(), tenantID, createdBy, body.Name, body.Description)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(fiber.Map{"data": folder})
}

// GET /api/v1/cba/folders — List all folders for this tenant
func (h *CBAHandler) GetFolders(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)

	folders, err := h.uc.GetFolders(c.Context(), tenantID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"data": folders})
}

// PUT /api/v1/cba/folders/:id/refresh-token — Refresh folder token (MANAGE_CBA)
func (h *CBAHandler) RefreshToken(c *fiber.Ctx) error {
	folderID, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid folder id"})
	}
	folder, err := h.uc.RefreshFolderToken(c.Context(), folderID)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{
		"message":          "token refreshed",
		"current_token":    folder.CurrentToken,
		"token_expires_at": folder.TokenExpiresAt,
	})
}

// POST /api/v1/cba/folders/:id/verify-token — Student verifies folder token to unlock exam list
func (h *CBAHandler) VerifyToken(c *fiber.Ctx) error {
	folderID, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid folder id"})
	}
	var body struct {
		Token string `json:"token"`
	}
	if err := c.BodyParser(&body); err != nil || body.Token == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "token is required"})
	}
	if err := h.uc.VerifyFolderToken(c.Context(), folderID, body.Token); err != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"message": "token verified — you may now view today's exams"})
}

// ==========================================
// EXAM MANAGEMENT (MANAGE_CBA permission)
// ==========================================

// POST /api/v1/cba/exams — Create a new exam inside a folder
func (h *CBAHandler) CreateExam(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)
	createdBy, _ := uuid.Parse(claims.UserID)

	var exam domain.CBAExam
	if err := c.BodyParser(&exam); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}
	if exam.Title == "" || exam.FolderID == uuid.Nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "title and folder_id are required"})
	}
	exam.TenantID = tenantID
	exam.CreatedBy = createdBy

	created, err := h.uc.CreateExam(c.Context(), &exam)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(fiber.Map{"data": created})
}

// POST /api/v1/cba/questions — Add a question to an exam
func (h *CBAHandler) AddCBAQuestion(c *fiber.Ctx) error {
	var q domain.CBAQuestion
	if err := c.BodyParser(&q); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}
	if q.QuestionText == "" || q.ExamID == uuid.Nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "question_text and exam_id are required"})
	}
	created, err := h.uc.AddCBAQuestion(c.Context(), &q)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(fiber.Map{"data": created})
}

// POST /api/v1/cba/options — Add options to a question
func (h *CBAHandler) AddCBAOption(c *fiber.Ctx) error {
	var opt domain.CBAOption
	if err := c.BodyParser(&opt); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}
	if opt.QuestionID == uuid.Nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "question_id is required"})
	}
	created, err := h.uc.AddCBAOption(c.Context(), &opt)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(fiber.Map{"data": created})
}

// ==========================================
// STUDENT EXAM FLOW
// ==========================================

// GET /api/v1/cba/folders/:id/exams — Get today's exams in a folder (after token verified)
func (h *CBAHandler) GetTodayExams(c *fiber.Ctx) error {
	folderID, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid folder id"})
	}
	exams, err := h.uc.GetTodayExams(c.Context(), folderID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"data": exams})
}

// POST /api/v1/cba/exams/:id/join — Student joins waiting room + reads T&C
func (h *CBAHandler) JoinWaitingRoom(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	studentID, _ := uuid.Parse(claims.UserID)
	examID, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid exam id"})
	}

	session, exam, err := h.uc.JoinWaitingRoom(c.Context(), examID, studentID)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{
		"message": "You have entered the waiting room",
		"session": session,
		"exam": fiber.Map{
			"id":                       exam.ID,
			"title":                    exam.Title,
			"terms_and_conditions":     exam.TermsAndConditions,
			"start_time":               exam.StartTime,
			"end_time":                 exam.EndTime,
			"status":                   exam.Status,
			"waiting_room_open_minutes": exam.WaitingRoomOpenMinutes,
		},
	})
}

// POST /api/v1/cba/exams/:id/start — Student starts the exam (server-time validated)
func (h *CBAHandler) StartExam(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	studentID, _ := uuid.Parse(claims.UserID)
	examID, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid exam id"})
	}

	session, err := h.uc.StartExam(c.Context(), examID, studentID)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{
		"message": "Exam started — good luck!",
		"session": session,
	})
}

// GET /api/v1/cba/exams/:id/questions — Get exam questions with current answer state
func (h *CBAHandler) GetExamQuestions(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	studentID, _ := uuid.Parse(claims.UserID)
	examID, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid exam id"})
	}

	questions, profile, err := h.uc.GetExamQuestions(c.Context(), examID, studentID)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{
		"student":   profile,
		"questions": questions,
	})
}

// POST /api/v1/cba/exams/:id/answers — Save/update one answer (ragu-ragu, previous/next nav)
func (h *CBAHandler) SaveAnswer(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	studentID, _ := uuid.Parse(claims.UserID)
	examID, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid exam id"})
	}

	var body struct {
		SessionID  string  `json:"session_id"`
		QuestionID string  `json:"question_id"`
		OptionID   *string `json:"option_id"`
		EssayText  string  `json:"essay_text"`
		IsDoubt    bool    `json:"is_doubt"`
	}
	if err := c.BodyParser(&body); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}

	sessionID, err := uuid.Parse(body.SessionID)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid session_id"})
	}
	questionID, err := uuid.Parse(body.QuestionID)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid question_id"})
	}
	var optionID *uuid.UUID
	if body.OptionID != nil && *body.OptionID != "" {
		oid, err := uuid.Parse(*body.OptionID)
		if err != nil {
			return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid option_id"})
		}
		optionID = &oid
	}
	_ = examID
	if err := h.uc.SaveAnswer(c.Context(), sessionID, questionID, optionID, body.EssayText, body.IsDoubt, studentID); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"message": "answer saved"})
}

// POST /api/v1/cba/exams/:id/submit — Student manually submits exam
func (h *CBAHandler) SubmitExam(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	studentID, _ := uuid.Parse(claims.UserID)
	examID, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid exam id"})
	}

	session, err := h.uc.SubmitExam(c.Context(), examID, studentID)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	resp := fiber.Map{
		"message": "Exam submitted successfully",
		"status":  session.Status,
	}
	if session.FinalScore != nil {
		resp["score"] = *session.FinalScore
	} else {
		resp["note"] = "Your results will be announced by the teacher."
	}
	return c.JSON(resp)
}

// ==========================================
// LMS QUIZ (Lightweight — existing)
// ==========================================

func (h *CBAHandler) CreateQuiz(c *fiber.Ctx) error {
	var quiz domain.Quiz
	if err := c.BodyParser(&quiz); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid body"})
	}
	if err := h.uc.CreateQuiz(c.Context(), &quiz); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(fiber.Map{"data": quiz})
}

func (h *CBAHandler) GetQuizzes(c *fiber.Ctx) error {
	moduleID, err := uuid.Parse(c.Query("module_id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid module_id"})
	}
	quizzes, err := h.uc.GetQuizzesByModule(c.Context(), moduleID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"data": quizzes})
}

func (h *CBAHandler) GetQuizByID(c *fiber.Ctx) error {
	id, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid id"})
	}
	quiz, err := h.uc.GetQuizByID(c.Context(), id)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"data": quiz})
}

func (h *CBAHandler) AddQuestion(c *fiber.Ctx) error {
	var q domain.Question
	if err := c.BodyParser(&q); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid body"})
	}
	if err := h.uc.AddQuestion(c.Context(), &q); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(fiber.Map{"data": q})
}

func (h *CBAHandler) AddOption(c *fiber.Ctx) error {
	var opt domain.QuestionOption
	if err := c.BodyParser(&opt); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid body"})
	}
	if err := h.uc.AddOption(c.Context(), &opt); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(fiber.Map{"data": opt})
}

func (h *CBAHandler) SubmitAnswer(c *fiber.Ctx) error {
	var answer domain.StudentAnswer
	if err := c.BodyParser(&answer); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid body"})
	}
	if err := h.uc.SubmitAnswer(c.Context(), &answer); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(fiber.Map{"message": "answer recorded"})
}

func (h *CBAHandler) GetStudentAnswers(c *fiber.Ctx) error {
	quizID, err := uuid.Parse(c.Query("quiz_id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid quiz_id"})
	}
	claims := c.Locals("claims").(*middleware.Claims)
	studentID, _ := uuid.Parse(claims.UserID)
	answers, err := h.uc.GetStudentAnswers(c.Context(), quizID, studentID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"data": answers})
}
