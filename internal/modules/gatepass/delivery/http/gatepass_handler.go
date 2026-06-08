package http

import (
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/middleware"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/gatepass/domain"
)

type GatePassHandler struct {
	uc domain.GatePassUsecase
}

func NewGatePassHandler(uc domain.GatePassUsecase) *GatePassHandler {
	return &GatePassHandler{uc: uc}
}

// POST /api/v1/gatepass/settings — Admin configures the approval chain
func (h *GatePassHandler) ConfigureSetting(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)

	var setting domain.GatePassSetting
	if err := c.BodyParser(&setting); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}
	if err := h.uc.ConfigureSetting(c.Context(), tenantID, &setting); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "gate pass settings saved"})
}

// GET /api/v1/gatepass/settings — Get approval chain config
func (h *GatePassHandler) GetSetting(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)

	setting, err := h.uc.GetSetting(c.Context(), tenantID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	if setting == nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "no gate pass settings found"})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"data": setting})
}

// POST /api/v1/gatepass/request — Student submits exit request
func (h *GatePassHandler) SubmitRequest(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	studentID, _ := uuid.Parse(claims.UserID)
	tenantID, _ := uuid.Parse(claims.TenantID)

	var body struct {
		Reason     string `json:"reason"`
		ExitTime   string `json:"exit_time"`   // RFC3339
		ReturnTime string `json:"return_time"` // RFC3339
	}
	if err := c.BodyParser(&body); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}

	exitTime, err := time.Parse(time.RFC3339, body.ExitTime)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "exit_time must be RFC3339 format"})
	}
	returnTime, err := time.Parse(time.RFC3339, body.ReturnTime)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "return_time must be RFC3339 format"})
	}

	pass, err := h.uc.SubmitRequest(c.Context(), tenantID, studentID, body.Reason, exitTime, returnTime)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(fiber.Map{
		"message": "exit request submitted, awaiting approvals",
		"data":    pass,
	})
}

// POST /api/v1/gatepass/:id/approve — Approver approves or rejects
func (h *GatePassHandler) ProcessApproval(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	approverID, _ := uuid.Parse(claims.UserID)
	tenantID, _ := uuid.Parse(claims.TenantID)

	gatePassID, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid gate pass id"})
	}

	var body struct {
		Approve bool `json:"approve"`
	}
	if err := c.BodyParser(&body); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}

	if err := h.uc.ProcessApproval(c.Context(), tenantID, approverID, gatePassID, body.Approve); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	action := "approved"
	if !body.Approve {
		action = "rejected"
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "gate pass " + action + " successfully"})
}

// POST /api/v1/gatepass/scan-exit — Guard scans exit QR → EXITED + return QR generated
func (h *GatePassHandler) ScanExitQR(c *fiber.Ctx) error {
	var body struct {
		Token string `json:"token"`
	}
	if err := c.BodyParser(&body); err != nil || body.Token == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "token is required"})
	}

	pass, err := h.uc.ScanExitQR(c.Context(), body.Token)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{
		"message": "Exit verified. Student has exited. Return QR generated.",
		"data": fiber.Map{
			"gate_pass_id":        pass.ID,
			"student_id":          pass.StudentID,
			"expected_return_time": pass.ExpectedReturnTime,
			"actual_exit_time":    pass.ActualExitTime,
			"return_qr_token":     pass.ReturnQRToken, // This shows on student's device
			"status":              pass.Status,
		},
	})
}

// POST /api/v1/gatepass/scan-return — Guard scans return QR → RETURNED
func (h *GatePassHandler) ScanReturnQR(c *fiber.Ctx) error {
	var body struct {
		Token string `json:"token"`
	}
	if err := c.BodyParser(&body); err != nil || body.Token == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "token is required"})
	}

	pass, err := h.uc.ScanReturnQR(c.Context(), body.Token)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{
		"message": "Student has returned successfully.",
		"data": fiber.Map{
			"gate_pass_id":       pass.ID,
			"student_id":         pass.StudentID,
			"actual_exit_time":   pass.ActualExitTime,
			"actual_return_time": pass.ActualReturnTime,
			"status":             pass.Status,
		},
	})
}
