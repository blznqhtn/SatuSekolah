package http

import (
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/middleware"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/pkg/domain"
)

type PkgHandler struct {
	uc domain.PkgUsecase
}

func NewPkgHandler(uc domain.PkgUsecase) *PkgHandler {
	return &PkgHandler{uc: uc}
}

// POST /api/v1/pkg/periods — Admin: create evaluation period
func (h *PkgHandler) CreatePeriod(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)

	var period domain.PkgPeriod
	if err := c.BodyParser(&period); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}
	period.TenantID = tenantID

	if err := h.uc.CreatePeriod(c.Context(), &period); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(fiber.Map{"message": "period created", "data": period})
}

// POST /api/v1/pkg/indicators — Admin: create evaluation indicator
func (h *PkgHandler) CreateIndicator(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)

	var indicator domain.PkgIndicator
	if err := c.BodyParser(&indicator); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}
	indicator.TenantID = tenantID

	if err := h.uc.CreateIndicator(c.Context(), &indicator); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(fiber.Map{"message": "indicator created", "data": indicator})
}

// GET /api/v1/pkg/indicators — List all indicators
func (h *PkgHandler) GetIndicators(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)

	indicators, err := h.uc.GetIndicators(c.Context(), tenantID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"data": indicators})
}

// POST /api/v1/pkg/submissions — Staff: upload evidence document
func (h *PkgHandler) SubmitDocument(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	StaffID, _ := uuid.Parse(claims.UserID)

	var submission domain.PkgSubmission
	if err := c.BodyParser(&submission); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}
	submission.StaffID = StaffID

	if err := h.uc.SubmitDocument(c.Context(), &submission); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(fiber.Map{"message": "document submitted", "data": submission})
}

// GET /api/v1/pkg/submissions?period_id=xxx — Staff: list my submissions
func (h *PkgHandler) GetMySubmissions(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	StaffID, _ := uuid.Parse(claims.UserID)
	periodID, err := uuid.Parse(c.Query("period_id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "period_id query param is required"})
	}

	subs, err := h.uc.GetMySubmissions(c.Context(), StaffID, periodID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"data": subs})
}

// POST /api/v1/pkg/evaluations — Admin/Principal: evaluate a submission
func (h *PkgHandler) EvaluateSubmission(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	evaluatorID, _ := uuid.Parse(claims.UserID)

	var eval domain.PkgEvaluation
	if err := c.BodyParser(&eval); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}
	eval.EvaluatorID = evaluatorID

	if err := h.uc.EvaluateSubmission(c.Context(), &eval); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(fiber.Map{"message": "evaluation recorded", "data": eval})
}

// GET /api/v1/pkg/average?staff_id=xxx&period_id=xxx — Admin: get fair average
func (h *PkgHandler) GetFairAverage(c *fiber.Ctx) error {
	StaffID, err := uuid.Parse(c.Query("staff_id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "staff_id query param is required"})
	}
	periodID, err := uuid.Parse(c.Query("period_id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "period_id query param is required"})
	}

	result, err := h.uc.CalculateFairAverage(c.Context(), StaffID, periodID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"data": result})
}
