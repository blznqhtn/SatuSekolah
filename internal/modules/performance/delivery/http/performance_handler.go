package http

import (
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/middleware"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/performance/domain"
)

type PerformanceHandler struct {
	pklUc domain.PklUsecase
}

func NewPerformanceHandler(pklUc domain.PklUsecase) *PerformanceHandler {
	return &PerformanceHandler{pklUc: pklUc}
}

// ------------------------------------------
// Existing PKL
// ------------------------------------------

func (h *PerformanceHandler) GetPerformances(c *fiber.Ctx) error {
	return c.JSON(fiber.Map{"message": "GetPerformances endpoint stub"})
}

func (h *PerformanceHandler) ReportPKL(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	staffID, _ := uuid.Parse(claims.UserID)
	tenantID, _ := uuid.Parse(claims.TenantID)

	var pkl domain.PklMonitoring
	if err := c.BodyParser(&pkl); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid body"})
	}
	pkl.TenantID = tenantID
	pkl.SupervisorStaffID = staffID

	if err := h.pklUc.ReportMonitoring(c.Context(), &pkl); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(fiber.Map{"message": "PKL monitoring reported", "data": pkl})
}

func (h *PerformanceHandler) EvaluatePKL(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	principalID, _ := uuid.Parse(claims.UserID)

	type req struct {
		PklID  string  `json:"pkl_id"`
		Score  float64 `json:"score"`
		Notes  string  `json:"notes"`
		Status string  `json:"status"`
	}
	var body req
	if err := c.BodyParser(&body); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid body"})
	}
	pklID, _ := uuid.Parse(body.PklID)

	if err := h.pklUc.EvaluateMonitoring(c.Context(), pklID, principalID, body.Score, body.Notes, domain.PklStatus(body.Status)); err != nil {
		return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "PKL monitoring evaluated"})
}

func (h *PerformanceHandler) ConfigureSetting(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	adminID, _ := uuid.Parse(claims.UserID)

	var setting domain.PerformanceSetting
	if err := c.BodyParser(&setting); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid body"})
	}

	if err := h.pklUc.ConfigureSetting(c.Context(), &setting, adminID); err != nil {
		return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "Performance settings configured", "data": setting})
}

// ------------------------------------------
// Mentorship
// ------------------------------------------

func (h *PerformanceHandler) AssignMentors(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)

	type req struct {
		AcademicYearID string   `json:"academic_year_id"`
		MentorID       string   `json:"mentor_id"`
		StudentIDs     []string `json:"student_ids"`
	}
	var body req
	if err := c.BodyParser(&body); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid body"})
	}

	mentorID, _ := uuid.Parse(body.MentorID)
	ayID, _ := uuid.Parse(body.AcademicYearID)
	var sIDs []uuid.UUID
	for _, id := range body.StudentIDs {
		sid, _ := uuid.Parse(id)
		sIDs = append(sIDs, sid)
	}

	if err := h.pklUc.AssignMentors(c.Context(), tenantID, ayID, sIDs, mentorID); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "Mentors assigned successfully"})
}

func (h *PerformanceHandler) CreateSchedule(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	mentorID, _ := uuid.Parse(claims.UserID)

	var schedule domain.PklMentoringSchedule
	if err := c.BodyParser(&schedule); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid body"})
	}

	if err := h.pklUc.CreateSchedule(c.Context(), mentorID, &schedule); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(fiber.Map{"message": "Schedule created", "data": schedule})
}

// ------------------------------------------
// Journals (Student)
// ------------------------------------------

func (h *PerformanceHandler) SubmitJournal(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	studentID, _ := uuid.Parse(claims.UserID)
	scheduleID, _ := uuid.Parse(c.Params("id"))

	type req struct {
		Description  string `json:"description"`   // e2ee cipher
		DocumentURLs string `json:"document_urls"` // Encrypted S3 URLs
	}
	var body req
	if err := c.BodyParser(&body); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid body"})
	}

	if err := h.pklUc.SubmitJournal(c.Context(), studentID, scheduleID, body.Description, body.DocumentURLs); err != nil {
		return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "Journal submitted"})
}

// ------------------------------------------
// Journals (Mentor)
// ------------------------------------------

func (h *PerformanceHandler) ReviewJournal(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	mentorID, _ := uuid.Parse(claims.UserID)
	journalID, _ := uuid.Parse(c.Params("id"))

	type req struct {
		Status   string `json:"status"`
		Feedback string `json:"feedback"` // e2ee cipher
	}
	var body req
	if err := c.BodyParser(&body); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid body"})
	}

	if err := h.pklUc.ReviewJournal(c.Context(), mentorID, journalID, domain.PklStatus(body.Status), body.Feedback); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "Journal reviewed"})
}

// ------------------------------------------
// Final Reports & Settings
// ------------------------------------------

func (h *PerformanceHandler) ConfigureFinalReportSetting(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)

	var setting domain.PklFinalReportSetting
	if err := c.BodyParser(&setting); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid body"})
	}

	if err := h.pklUc.ConfigureFinalReport(c.Context(), tenantID, &setting); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "Final report settings configured", "data": setting})
}

func (h *PerformanceHandler) SubmitFinalReport(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)
	studentID, _ := uuid.Parse(claims.UserID)

	type req struct {
		DocumentURL string `json:"document_url"`
	}
	var body req
	if err := c.BodyParser(&body); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid body"})
	}

	if err := h.pklUc.SubmitFinalReport(c.Context(), tenantID, studentID, body.DocumentURL); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "Final report submitted"})
}

func (h *PerformanceHandler) VerifyFinalReport(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)
	hubinID, _ := uuid.Parse(claims.UserID)
	reportID, _ := uuid.Parse(c.Params("id"))

	type req struct {
		Status string `json:"status"`
		Notes  string `json:"notes"`
	}
	var body req
	if err := c.BodyParser(&body); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid body"})
	}

	if err := h.pklUc.VerifyFinalReport(c.Context(), tenantID, hubinID, reportID, domain.PklStatus(body.Status), body.Notes); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "Final report verified"})
}

// ------------------------------------------
// Hubin Monitoring
// ------------------------------------------

func (h *PerformanceHandler) ReportHubinMonitoring(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)
	staffID, _ := uuid.Parse(claims.UserID)

	type req struct {
		FileURL string `json:"file_url"`
		Title   string `json:"title"`
	}
	var body req
	if err := c.BodyParser(&body); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid body"})
	}

	if err := h.pklUc.ReportHubinMonitoring(c.Context(), tenantID, staffID, body.FileURL, body.Title); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "Monitoring report submitted successfully"})
}
