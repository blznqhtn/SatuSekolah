package http

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/middleware"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/portfolio/domain"
	"neuracakrawira.asia/satu-sekolah-backend/pkg/utils"
)

type PortfolioHandler struct {
	usecase domain.PortfolioUsecase
}

func NewPortfolioHandler(usecase domain.PortfolioUsecase) *PortfolioHandler {
	return &PortfolioHandler{usecase: usecase}
}

func (h *PortfolioHandler) GetMyPortfolio(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	userID, _ := uuid.Parse(claims.UserID)

	port, err := h.usecase.GetMyPortfolio(c.Context(), userID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"data": port})
}

func (h *PortfolioHandler) UpdateSummary(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	userID, _ := uuid.Parse(claims.UserID)

	var req struct {
		Summary string `json:"summary"`
		CVUrl   string `json:"cv_url"`
	}
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "request tidak valid"})
	}

	port, err := h.usecase.UpdateSummary(c.Context(), userID, req.Summary, req.CVUrl)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "Summary updated", "data": port})
}

func (h *PortfolioHandler) AddExperience(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	userID, _ := uuid.Parse(claims.UserID)

	var req domain.PortfolioExperience
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "request tidak valid"})
	}

	if err := h.usecase.AddExperience(c.Context(), userID, &req); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(fiber.Map{"message": "Experience added"})
}

func (h *PortfolioHandler) ImportLinkedInPDF(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	userID, _ := uuid.Parse(claims.UserID)

	file, err := c.FormFile("pdf")
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "File PDF tidak ditemukan"})
	}
	
	// Validasi Magic Bytes: Pastikan benar-benar PDF dan bukan script tersembunyi
	if err := utils.ValidateFileMagicBytes(file, []string{"application/pdf"}); err != nil {
		return c.Status(fiber.StatusUnsupportedMediaType).JSON(fiber.Map{"error": "Invalid or malicious file detected. Only true PDF files are allowed."})
	}

	// 1. Save file to temporary path
	tempPath := filepath.Join(os.TempDir(), fmt.Sprintf("%s.pdf", uuid.New().String()))
	if err := c.SaveFile(file, tempPath); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Gagal menyimpan file PDF"})
	}

	if err := h.usecase.ExtractPortfolioFromLinkedInPDF(c.Context(), userID, tempPath); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "Portfolio berhasil diekstrak dari LinkedIn PDF"})
}
