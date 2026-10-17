package http

import (
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/middleware"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/career/domain"
)

type CareerHandler struct {
	usecase domain.CareerUsecase
}

func NewCareerHandler(usecase domain.CareerUsecase) *CareerHandler {
	return &CareerHandler{usecase: usecase}
}

func (h *CareerHandler) CreateJobVacancy(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)

	var req domain.JobVacancy
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "request tidak valid"})
	}
	req.TenantID = tenantID

	if err := h.usecase.CreateJobVacancy(c.Context(), &req); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(fiber.Map{"message": "Lowongan kerja berhasil dibuat", "data": req})
}

func (h *CareerHandler) GetLocalJobs(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)

	jobs, err := h.usecase.GetLocalJobs(c.Context(), tenantID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"data": jobs})
}

func (h *CareerHandler) GetPublicJobs(c *fiber.Ctx) error {
	jobs, err := h.usecase.GetPublicJobs(c.Context())
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"data": jobs})
}

func (h *CareerHandler) ApplyJob(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	userID, _ := uuid.Parse(claims.UserID)
	jobID, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "ID lowongan tidak valid"})
	}

	var req struct {
		ResumeUrl string `json:"resume_url"`
	}
	c.BodyParser(&req)

	if err := h.usecase.ApplyJob(c.Context(), userID, jobID, req.ResumeUrl); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(fiber.Map{"message": "Berhasil melamar pekerjaan"})
}

func (h *CareerHandler) GetMyApplications(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	userID, _ := uuid.Parse(claims.UserID)

	apps, err := h.usecase.GetMyApplications(c.Context(), userID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"data": apps})
}

func (h *CareerHandler) GetJobApplications(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)
	jobID, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "ID lowongan tidak valid"})
	}

	apps, err := h.usecase.GetJobApplications(c.Context(), tenantID, jobID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"data": apps})
}

func (h *CareerHandler) ReviewApplication(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)
	appID, err := uuid.Parse(c.Params("appId"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "ID lamaran tidak valid"})
	}

	var req struct {
		Status domain.JobApplicationStatus `json:"status"`
	}
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "request tidak valid"})
	}

	if err := h.usecase.ReviewApplication(c.Context(), tenantID, appID, req.Status); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "Status lamaran berhasil diubah"})
}
