package http

import (
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/middleware"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/evaluation/domain"
)

type EvaluationHandler struct {
	uc domain.EvaluationUsecase
}

func NewEvaluationHandler(uc domain.EvaluationUsecase) *EvaluationHandler {
	return &EvaluationHandler{uc: uc}
}

// GET /api/v1/evaluations/categories
func (h *EvaluationHandler) GetCategories(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)

	categories, err := h.uc.GetCategories(c.Context(), tenantID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"data": categories})
}

// GET /api/v1/evaluations/active-period
func (h *EvaluationHandler) GetActivePeriod(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)

	period, err := h.uc.GetActivePeriod(c.Context(), tenantID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	if period == nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "no active evaluation period"})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"data": period})
}

// GET /api/v1/evaluations/teachers/eligible
func (h *EvaluationHandler) GetEligibleTeachers(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)
	studentID, _ := uuid.Parse(claims.UserID)

	teachers, err := h.uc.GetEligibleTeachers(c.Context(), tenantID, studentID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"data": teachers})
}

// POST /api/v1/evaluations/submit
func (h *EvaluationHandler) SubmitEvaluation(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)
	evaluatorID, _ := uuid.Parse(claims.UserID)

	var req domain.SubmitEvaluationRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}

	if err := h.uc.SubmitEvaluation(c.Context(), tenantID, evaluatorID, &req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(fiber.Map{"message": "evaluation submitted successfully"})
}

// GET /api/v1/evaluations/results/:teacherId
func (h *EvaluationHandler) GetTeacherResults(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)

	teacherID, err := uuid.Parse(c.Params("teacherId"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid teacher id"})
	}

	// Usually results are per period, we will get it from query param, or fallback to active
	periodIDStr := c.Query("period_id")
	var periodID uuid.UUID
	if periodIDStr == "" {
		period, err := h.uc.GetActivePeriod(c.Context(), tenantID)
		if err != nil || period == nil {
			return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "no active evaluation period"})
		}
		periodID = period.ID
	} else {
		periodID, err = uuid.Parse(periodIDStr)
		if err != nil {
			return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid period_id"})
		}
	}

	results, err := h.uc.GetTeacherResults(c.Context(), tenantID, periodID, teacherID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"data": results})
}
