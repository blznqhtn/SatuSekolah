package http

import (
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/middleware"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/reports/domain"
)

type ReportHandler struct {
	uc domain.ReportUsecase
}

func NewReportHandler(uc domain.ReportUsecase) *ReportHandler {
	return &ReportHandler{uc: uc}
}

func (h *ReportHandler) GetAttendanceReport(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)

	startDate, _ := time.Parse("2006-01-02", c.Query("start_date", time.Now().AddDate(0, -1, 0).Format("2006-01-02")))
	endDate, _ := time.Parse("2006-01-02", c.Query("end_date", time.Now().Format("2006-01-02")))
	format := domain.ReportFormat(c.Query("format", string(domain.FormatJSON)))

	data, contentType, err := h.uc.GenerateAttendanceReport(c.Context(), tenantID, startDate, endDate, format)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	if format == domain.FormatJSON {
		return c.Status(fiber.StatusOK).JSON(fiber.Map{"data": data})
	}

	c.Set("Content-Type", contentType)
	c.Set("Content-Disposition", `attachment; filename="attendance_report.`+string(format)+`"`)
	return c.Send(data.([]byte))
}

func (h *ReportHandler) GetFinancialReport(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)

	startDate, _ := time.Parse("2006-01-02", c.Query("start_date", time.Now().AddDate(0, -1, 0).Format("2006-01-02")))
	endDate, _ := time.Parse("2006-01-02", c.Query("end_date", time.Now().Format("2006-01-02")))
	format := domain.ReportFormat(c.Query("format", string(domain.FormatJSON)))

	data, contentType, err := h.uc.GenerateFinancialReport(c.Context(), tenantID, startDate, endDate, format)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	if format == domain.FormatJSON {
		return c.Status(fiber.StatusOK).JSON(fiber.Map{"data": data})
	}

	c.Set("Content-Type", contentType)
	c.Set("Content-Disposition", `attachment; filename="financial_report.`+string(format)+`"`)
	return c.Send(data.([]byte))
}

func (h *ReportHandler) GetAcademicReport(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)
	format := domain.ReportFormat(c.Query("format", string(domain.FormatJSON)))

	data, contentType, err := h.uc.GenerateAcademicReport(c.Context(), tenantID, format)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	if format == domain.FormatJSON {
		return c.Status(fiber.StatusOK).JSON(fiber.Map{"data": data})
	}

	c.Set("Content-Type", contentType)
	c.Set("Content-Disposition", `attachment; filename="academic_report.`+string(format)+`"`)
	return c.Send(data.([]byte))
}
