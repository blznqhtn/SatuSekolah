package http

import (
	"fmt"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/middleware"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/academic/domain"
	"neuracakrawira.asia/satu-sekolah-backend/pkg/utils"
)

type ReportCardHandler struct {
	uc domain.ReportCardUsecase
}

func NewReportCardHandler(uc domain.ReportCardUsecase) *ReportCardHandler {
	return &ReportCardHandler{uc: uc}
}

// GET /api/v1/academic/report-cards/template?class_id=xxx
func (h *ReportCardHandler) GetTemplate(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)

	classIDStr := c.Query("class_id")
	if classIDStr == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "class_id query param is required"})
	}

	classID, err := uuid.Parse(classIDStr)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid class_id"})
	}

	templateBytes, err := h.uc.GenerateExcelTemplate(c.Context(), tenantID, classID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	c.Set("Content-Type", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
	c.Set("Content-Disposition", fmt.Sprintf("attachment; filename=Template_Nilai_Kelas_%s.xlsx", classID.String()))
	return c.Send(templateBytes)
}

// POST /api/v1/academic/report-cards/upload
func (h *ReportCardHandler) UploadGrades(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)
	uploadedBy, _ := uuid.Parse(claims.UserID)

	termIDStr := c.FormValue("term_id")
	if termIDStr == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "term_id form data is required"})
	}

	termID, err := uuid.Parse(termIDStr)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid term_id"})
	}

	file, err := c.FormFile("file")
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "file form data is required"})
	}

	// Validasi Magic Bytes: Cegah unggahan script berbahaya berkedok file Excel/CSV
	allowedTypes := []string{
		"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", // .xlsx
		"application/vnd.ms-excel", // .xls
		"text/csv",                 // .csv
	}
	if err := utils.ValidateFileMagicBytes(file, allowedTypes); err != nil {
		return c.Status(fiber.StatusUnsupportedMediaType).JSON(fiber.Map{"error": "Invalid or malicious file detected. Only Excel/CSV files are allowed."})
	}

	if err := h.uc.UploadExcelGrades(c.Context(), tenantID, termID, uploadedBy, file); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "Grades uploaded successfully"})
}

// GET /api/v1/academic/report-cards/leaderboard?term_id=xxx&filter=class|major|grade|all&filter_id=yyy
func (h *ReportCardHandler) GetLeaderboard(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)

	termIDStr := c.Query("term_id")
	if termIDStr == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "term_id query param is required"})
	}
	termID, err := uuid.Parse(termIDStr)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid term_id"})
	}

	filterStr := c.Query("filter")
	filterIDStr := c.Query("filter_id")

	var filter domain.LeaderboardFilter
	switch filterStr {
	case "class":
		filter = domain.LeaderboardClass
	case "major":
		filter = domain.LeaderboardMajor
	case "grade":
		filter = domain.LeaderboardGrade
	case "all":
		filter = domain.LeaderboardAll
	default:
		filter = domain.LeaderboardAll
	}

	if filter != domain.LeaderboardAll && filterIDStr == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "filter_id query param is required for this filter"})
	}

	leaderboard, err := h.uc.GetLeaderboard(c.Context(), tenantID, termID, filter, filterIDStr)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{
		"message": "success",
		"data":    leaderboard,
	})
}
