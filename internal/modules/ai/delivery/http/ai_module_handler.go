package http

import (
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/middleware"
	aiDomain "neuracakrawira.asia/satu-sekolah-backend/internal/modules/ai/domain"
)

// AIModuleHandler handles AI feature management (toggle per module + limit config).
type AIModuleHandler struct {
	uc aiDomain.AIModuleUsecase
}

func NewAIModuleHandler(uc aiDomain.AIModuleUsecase) *AIModuleHandler {
	return &AIModuleHandler{uc: uc}
}

// GET /api/v1/admin/ai/modules
// Returns the AI activation status and usage stats for all known modules in this tenant.
func (h *AIModuleHandler) ListModules(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, err := uuid.Parse(claims.TenantID)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid tenant_id in token"})
	}

	settings, err := h.uc.ListModuleSettings(c.Context(), tenantID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	// Enrich response with module descriptions
	type ModuleInfo struct {
		*aiDomain.AIModuleSetting
		Description string `json:"description"`
	}

	descriptions := map[string]string{
		"HEALTH":          "UKS: Analisis rekam medis & saran kesehatan reproduksi (siklus haid)",
		"CANTEEN":         "Kantin Digital: Laporan bisnis bulanan & saran profitabilitas otomatis",
		"ACADEMIC_REPORT": "Akademik: Generasi narasi raport / komentar wali kelas otomatis",
		"VIOLATIONS":      "Kesiswaan: Analisis pola pelanggaran & rekomendasi tindakan pembinaan",
		"LIBRARY":         "Perpustakaan: Rekomendasi buku & jurnal berdasarkan riwayat peminjaman",
		"PKL":             "PKL: Umpan balik otomatis untuk jurnal bimbingan siswa PKL",
	}

	enriched := make([]ModuleInfo, 0, len(settings))
	for _, s := range settings {
		desc := descriptions[s.ModuleName]
		if desc == "" {
			desc = "Fitur AI khusus"
		}
		enriched = append(enriched, ModuleInfo{AIModuleSetting: s, Description: desc})
	}

	return c.JSON(fiber.Map{
		"data": fiber.Map{
			"tenant_id": tenantID,
			"modules":   enriched,
			"note":      "daily_limit & monthly_limit = 0 means unlimited",
		},
	})
}

// PUT /api/v1/admin/ai/modules/:module
// Toggle AI on/off for a specific module and configure limits.
// Requires: MANAGE_AI permission or Admin role.
func (h *AIModuleHandler) UpdateModule(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	requesterID, err := uuid.Parse(claims.UserID)
	if err != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "invalid user identity"})
	}
	tenantID, err := uuid.Parse(claims.TenantID)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid tenant_id in token"})
	}

	moduleName := c.Params("module")
	if moduleName == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "module name is required as path param"})
	}

	var body struct {
		IsActive     bool `json:"is_active"`
		DailyLimit   int  `json:"daily_limit"`   // 0 = unlimited
		MonthlyLimit int  `json:"monthly_limit"` // 0 = unlimited
	}
	if err := c.BodyParser(&body); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}

	setting, err := h.uc.UpdateModuleSetting(c.Context(), requesterID, tenantID, moduleName, body.IsActive, body.DailyLimit, body.MonthlyLimit)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(fiber.Map{
		"message": "AI module setting updated successfully",
		"data":    setting,
	})
}

// GET /api/v1/admin/ai/modules/:module/status
// Check the current allow/deny status & usage for a specific module (for admin dashboard).
func (h *AIModuleHandler) CheckModuleStatus(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, err := uuid.Parse(claims.TenantID)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid tenant_id in token"})
	}

	moduleName := c.Params("module")
	if moduleName == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "module name is required"})
	}

	result, err := h.uc.CheckModuleAllowed(c.Context(), tenantID, moduleName)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(fiber.Map{"data": result})
}
