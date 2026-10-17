package handlers

import (
	"github.com/gofiber/fiber/v2"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/academic/requests"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/academic/services"
	"neuracakrawira.asia/satu-sekolah-backend/pkg/validator"
)

type academicHandler struct {
	ayService    services.AcademicYearService
	majorService services.MajorService
	classService services.ClassService
	validator    *validator.GoPlaygroundValidator
}

func NewAcademicHandler(
	ayService services.AcademicYearService,
	majorService services.MajorService,
	classService services.ClassService,
	validator *validator.GoPlaygroundValidator,
) (AcademicYearHandler, MajorHandler, ClassHandler) {
	return &academicHandler{ayService: ayService, validator: validator},
		&academicHandler{majorService: majorService, validator: validator},
		&academicHandler{classService: classService, validator: validator}
}

func (h *academicHandler) CreateAcademicYear(c *fiber.Ctx) error {
	var req requests.CreateAcademicYearRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": true, "msg": err.Error()})
	}
	if err := h.validator.Validate(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": true, "msg": err.Error()})
	}
	ay, err := h.ayService.CreateAcademicYear(c.Context(), &req)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": true, "msg": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(ay)
}

func (h *academicHandler) CreateMajor(c *fiber.Ctx) error {
	var req requests.CreateMajorRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": true, "msg": err.Error()})
	}
	if err := h.validator.Validate(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": true, "msg": err.Error()})
	}
	major, err := h.majorService.CreateMajor(c.Context(), &req)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": true, "msg": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(major)
}

func (h *academicHandler) CreateClass(c *fiber.Ctx) error {
	var req requests.CreateClassRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": true, "msg": err.Error()})
	}
	if err := h.validator.Validate(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": true, "msg": err.Error()})
	}
	class, err := h.classService.CreateClass(c.Context(), &req)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": true, "msg": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(class)
}
