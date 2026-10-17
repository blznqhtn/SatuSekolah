package http

import (
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/middleware"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/academic/domain"
)

// =============================================================================
// STUDENT PERMIT HANDLER
// =============================================================================

type PermitHandler struct {
	uc domain.PermitUsecase
}

func NewPermitHandler(uc domain.PermitUsecase) *PermitHandler {
	return &PermitHandler{uc: uc}
}

// POST /api/v1/academic/permits — Student: submit izin
func (h *PermitHandler) SubmitPermit(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	studentID, _ := uuid.Parse(claims.UserID)
	tenantID, _ := uuid.Parse(claims.TenantID)

	var body struct {
		Type          string `json:"type"`
		Reason        string `json:"reason"`
		StartDate     string `json:"start_date"`
		EndDate       string `json:"end_date"`
		AttachmentURL string `json:"attachment_url"`
	}
	if err := c.BodyParser(&body); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}

	startDate, err := time.Parse("2006-01-02", body.StartDate)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "format start_date harus YYYY-MM-DD"})
	}
	endDate, err := time.Parse("2006-01-02", body.EndDate)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "format end_date harus YYYY-MM-DD"})
	}

	permit := &domain.StudentPermit{
		TenantID:      tenantID,
		StudentID:     studentID,
		Type:          domain.PermitType(body.Type),
		Reason:        body.Reason,
		StartDate:     startDate,
		EndDate:       endDate,
		AttachmentURL: body.AttachmentURL,
	}

	if err := h.uc.SubmitPermit(c.Context(), permit); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(fiber.Map{"message": "izin berhasil diajukan", "data": permit})
}

// GET /api/v1/academic/permits/my — Student: lihat izin saya
func (h *PermitHandler) GetMyPermits(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	studentID, _ := uuid.Parse(claims.UserID)
	tenantID, _ := uuid.Parse(claims.TenantID)

	permits, err := h.uc.GetMyPermits(c.Context(), tenantID, studentID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"data": permits})
}

// GET /api/v1/academic/permits/pending — Staff/Admin: lihat izin pending
func (h *PermitHandler) GetPendingPermits(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)

	permits, err := h.uc.GetPendingPermits(c.Context(), tenantID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"data": permits})
}

// PATCH /api/v1/academic/permits/:id/review — Staff: setujui/tolak izin
func (h *PermitHandler) ReviewPermit(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	reviewerID, _ := uuid.Parse(claims.UserID)
	permitID, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "permit id tidak valid"})
	}

	var body struct {
		Status string `json:"status"` // "APPROVED" | "REJECTED"
		Note   string `json:"note"`
	}
	if err := c.BodyParser(&body); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}

	if err := h.uc.ReviewPermit(c.Context(), permitID, reviewerID, domain.PermitStatus(body.Status), body.Note); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"message": "izin berhasil diproses"})
}

// =============================================================================
// COUNSELING HANDLER
// =============================================================================

type CounselingHandler struct {
	uc domain.CounselingUsecase
}

func NewCounselingHandler(uc domain.CounselingUsecase) *CounselingHandler {
	return &CounselingHandler{uc: uc}
}

// POST /api/v1/academic/counseling/book — Student: ajukan sesi BK
func (h *CounselingHandler) BookSession(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	studentID, _ := uuid.Parse(claims.UserID)
	tenantID, _ := uuid.Parse(claims.TenantID)

	var body struct {
		Topic         string `json:"topic"`
		Description   string `json:"description"`
		PreferredDate string `json:"preferred_date"` // "2026-10-20"
	}
	if err := c.BodyParser(&body); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}

	preferredDate, err := time.Parse("2006-01-02", body.PreferredDate)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "format preferred_date harus YYYY-MM-DD"})
	}

	session := &domain.CounselingSession{
		TenantID:      tenantID,
		StudentID:     studentID,
		Topic:         body.Topic,
		Description:   body.Description,
		PreferredDate: preferredDate,
	}

	if err := h.uc.BookSession(c.Context(), session); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(fiber.Map{"message": "sesi BK berhasil diajukan", "data": session})
}

// GET /api/v1/academic/counseling/my — Student: lihat sesi BK saya
func (h *CounselingHandler) GetMySessions(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	studentID, _ := uuid.Parse(claims.UserID)
	tenantID, _ := uuid.Parse(claims.TenantID)

	sessions, err := h.uc.GetMySessions(c.Context(), tenantID, studentID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"data": sessions})
}

// GET /api/v1/academic/counseling — Counselor/Admin: lihat semua sesi
func (h *CounselingHandler) GetAllSessions(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)

	sessions, err := h.uc.GetAllSessions(c.Context(), tenantID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"data": sessions})
}

// PATCH /api/v1/academic/counseling/:id/schedule — Counselor: jadwalkan sesi BK
func (h *CounselingHandler) ScheduleSession(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	counselorID, _ := uuid.Parse(claims.UserID)
	sessionID, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "session id tidak valid"})
	}

	var body struct {
		ScheduledAt string `json:"scheduled_at"` // "2026-10-22"
		Notes       string `json:"notes"`
	}
	if err := c.BodyParser(&body); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}

	scheduledAt, err := time.Parse("2006-01-02", body.ScheduledAt)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "format scheduled_at harus YYYY-MM-DD"})
	}

	if err := h.uc.ScheduleSession(c.Context(), sessionID, counselorID, scheduledAt, body.Notes); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"message": "sesi BK berhasil dijadwalkan"})
}

// =============================================================================
// EXTRACURRICULAR HANDLER
// =============================================================================

type ExtracurricularHandler struct {
	uc domain.ExtracurricularUsecase
}

func NewExtracurricularHandler(uc domain.ExtracurricularUsecase) *ExtracurricularHandler {
	return &ExtracurricularHandler{uc: uc}
}

// GET /api/v1/academic/extracurriculars — List semua ekskul aktif
func (h *ExtracurricularHandler) GetAll(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)

	extras, err := h.uc.GetAll(c.Context(), tenantID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"data": extras})
}

// POST /api/v1/academic/extracurriculars — Admin: tambah ekskul baru
func (h *ExtracurricularHandler) Create(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)

	var extra domain.Extracurricular
	if err := c.BodyParser(&extra); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}
	extra.TenantID = tenantID

	if err := h.uc.Create(c.Context(), &extra); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(fiber.Map{"message": "ekstrakulikuler berhasil dibuat", "data": extra})
}

// POST /api/v1/academic/extracurriculars/:id/register — Student: daftar ekskul
func (h *ExtracurricularHandler) Register(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	studentID, _ := uuid.Parse(claims.UserID)
	tenantID, _ := uuid.Parse(claims.TenantID)
	extraID, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "extracurricular id tidak valid"})
	}

	if err := h.uc.Register(c.Context(), tenantID, studentID, extraID); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(fiber.Map{"message": "pendaftaran ekskul berhasil diajukan"})
}

// GET /api/v1/academic/extracurriculars/my — Student: lihat ekskul saya
func (h *ExtracurricularHandler) GetMyRegistrations(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	studentID, _ := uuid.Parse(claims.UserID)
	tenantID, _ := uuid.Parse(claims.TenantID)

	regs, err := h.uc.GetMyRegistrations(c.Context(), tenantID, studentID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"data": regs})
}

// PATCH /api/v1/academic/extracurriculars/registrations/:id/approve — Admin
func (h *ExtracurricularHandler) ApproveRegistration(c *fiber.Ctx) error {
	regID, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "registration id tidak valid"})
	}
	if err := h.uc.ApproveRegistration(c.Context(), regID); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"message": "pendaftaran disetujui"})
}

// PATCH /api/v1/academic/extracurriculars/registrations/:id/reject — Admin
func (h *ExtracurricularHandler) RejectRegistration(c *fiber.Ctx) error {
	regID, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "registration id tidak valid"})
	}
	if err := h.uc.RejectRegistration(c.Context(), regID); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"message": "pendaftaran ditolak"})
}
