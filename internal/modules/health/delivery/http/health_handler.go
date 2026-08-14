package http

import (
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/middleware"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/health/domain"
)

type HealthHandler struct {
	uc domain.HealthUsecase
}

func NewHealthHandler(uc domain.HealthUsecase) *HealthHandler {
	return &HealthHandler{uc: uc}
}

// GET /api/v1/health/records — User: view own health records
func (h *HealthHandler) GetRecords(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	userID, _ := uuid.Parse(claims.UserID)

	records, err := h.uc.GetMyHealthRecords(c.Context(), userID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"data": records})
}

// POST /api/v1/health/records — Health Admin: add health record for a user (TB, BB, HB, etc.)
func (h *HealthHandler) AddHealthRecord(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	adminID, _ := uuid.Parse(claims.UserID)

	var record domain.HealthRecord
	if err := c.BodyParser(&record); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}
	tenantID, _ := uuid.Parse(claims.TenantID)
	record.TenantID = tenantID

	if err := h.uc.AddHealthRecord(c.Context(), &record, adminID); err != nil {
		return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(fiber.Map{"message": "health record added", "data": record})
}

// POST /api/v1/health/cycles/start — Female user: start menstrual cycle
func (h *HealthHandler) StartCycle(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	userID, _ := uuid.Parse(claims.UserID)
	tenantID, _ := uuid.Parse(claims.TenantID)

	type startReq struct {
		Symptoms string `json:"symptoms"`
	}
	var req startReq
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}

	cycle, err := h.uc.StartMenstrualCycle(c.Context(), tenantID, userID, req.Symptoms)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(fiber.Map{"message": "menstrual cycle started", "data": cycle})
}

// POST /api/v1/health/cycles/stop — Female user: stop menstrual cycle (blocked if > 7 days)
func (h *HealthHandler) StopCycle(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	userID, _ := uuid.Parse(claims.UserID)

	if err := h.uc.StopMenstrualCycle(c.Context(), userID); err != nil {
		return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "menstrual cycle stopped successfully"})
}

// POST /api/v1/health/ribbons/borrow — Female student only: borrow a ribbon
func (h *HealthHandler) BorrowRibbon(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	userID, _ := uuid.Parse(claims.UserID)
	tenantID, _ := uuid.Parse(claims.TenantID)

	ribbon, err := h.uc.BorrowRibbon(c.Context(), tenantID, userID)
	if err != nil {
		return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(fiber.Map{"message": "ribbon borrowed", "data": ribbon})
}

// GET /api/v1/health/watchlist — Health Admin: view overdue cycles & ribbons
func (h *HealthHandler) GetOverdueWatchlist(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	adminID, _ := uuid.Parse(claims.UserID)
	tenantID, _ := uuid.Parse(claims.TenantID)

	cycles, ribbons, err := h.uc.GetOverdueWatchlist(c.Context(), tenantID, adminID)
	if err != nil {
		return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{
		"overdue_cycles":  cycles,
		"overdue_ribbons": ribbons,
	})
}

// POST /api/v1/admin/health/settings — Admin: assign health admin Staff
func (h *HealthHandler) ConfigureSetting(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	requesterID, _ := uuid.Parse(claims.UserID)

	var setting domain.HealthSetting
	if err := c.BodyParser(&setting); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}

	if err := h.uc.ConfigureSetting(c.Context(), &setting, requesterID); err != nil {
		return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "health setting configured", "data": setting})
}

// POST /api/v1/health/force-stop — Health Admin: force stop overdue cycle & ribbon
func (h *HealthHandler) ForceStopCycle(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	adminID, _ := uuid.Parse(claims.UserID)

	type forceReq struct {
		CycleID       string `json:"cycle_id"`
		SanctionNotes string `json:"sanction_notes"`
	}
	var req forceReq
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}
	cycleID, err := uuid.Parse(req.CycleID)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid cycle_id"})
	}

	if err := h.uc.ForceStopCycleAndRibbon(c.Context(), cycleID, adminID, req.SanctionNotes); err != nil {
		return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "cycle and ribbon force-stopped"})
}

// ==========================================
// UKS Health Endpoints
// ==========================================

// GET /api/v1/health/student/:studentId/summary
func (h *HealthHandler) GetStudentHealthSummary(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)
	studentIDStr := c.Params("studentId")
	studentID, err := uuid.Parse(studentIDStr)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid student_id"})
	}

	summary, err := h.uc.GetStudentHealthSummary(c.Context(), tenantID, studentID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "success", "data": summary})
}

// GET /api/v1/health/student/:studentId/checkups
func (h *HealthHandler) GetStudentCheckups(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)
	studentIDStr := c.Params("studentId")
	studentID, err := uuid.Parse(studentIDStr)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid student_id"})
	}

	checkups, err := h.uc.GetStudentCheckups(c.Context(), tenantID, studentID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "success", "data": checkups})
}

// POST /api/v1/health/checkups
func (h *HealthHandler) AddHealthCheckup(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)
	examinerID, _ := uuid.Parse(claims.UserID)

	var req domain.HealthCheckup
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}
	req.TenantID = tenantID
	req.ExaminerID = examinerID

	if err := h.uc.AddHealthCheckup(c.Context(), &req); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(fiber.Map{"message": "checkup added successfully", "data": req})
}

// GET /api/v1/health/student/:studentId/history
func (h *HealthHandler) GetStudentMedicalHistory(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)
	studentIDStr := c.Params("studentId")
	studentID, err := uuid.Parse(studentIDStr)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid student_id"})
	}

	history, err := h.uc.GetStudentMedicalHistory(c.Context(), tenantID, studentID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	// return empty struct instead of null if empty
	if history == nil {
		history = &domain.MedicalHistory{StudentID: studentID, TenantID: tenantID}
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "success", "data": history})
}

// PUT /api/v1/health/student/:studentId/history
func (h *HealthHandler) UpdateMedicalHistory(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)
	studentIDStr := c.Params("studentId")
	studentID, err := uuid.Parse(studentIDStr)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid student_id"})
	}

	var req domain.MedicalHistory
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}
	req.TenantID = tenantID
	req.StudentID = studentID

	if err := h.uc.UpdateMedicalHistory(c.Context(), &req); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "medical history updated successfully"})
}
