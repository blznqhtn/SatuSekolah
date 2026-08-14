package http

import (
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/middleware"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/academic/domain"
)

type AcademicHandler struct {
	uc domain.AcademicUsecase
}

func NewAcademicHandler(uc domain.AcademicUsecase) *AcademicHandler {
	return &AcademicHandler{uc: uc}
}

// POST /api/v1/academic/courses — Staff: create a course
func (h *AcademicHandler) CreateCourse(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	StaffID, _ := uuid.Parse(claims.UserID)
	tenantID, _ := uuid.Parse(claims.TenantID)

	var course domain.Course
	if err := c.BodyParser(&course); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}
	course.StaffID = StaffID
	course.TenantID = tenantID

	if err := h.uc.CreateCourse(c.Context(), &course); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(fiber.Map{"message": "course created", "data": course})
}

// GET /api/v1/academic/courses — List courses for tenant
func (h *AcademicHandler) GetCourses(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	tenantID, _ := uuid.Parse(claims.TenantID)

	courses, err := h.uc.GetCourses(c.Context(), tenantID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"data": courses})
}

// POST /api/v1/academic/modules — Staff: add module to course
func (h *AcademicHandler) CreateModule(c *fiber.Ctx) error {
	var module domain.CourseModule
	if err := c.BodyParser(&module); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}
	if err := h.uc.CreateModule(c.Context(), &module); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(fiber.Map{"message": "module created", "data": module})
}

// GET /api/v1/academic/modules?course_id=xxx — List modules for a course
func (h *AcademicHandler) GetModules(c *fiber.Ctx) error {
	courseID, err := uuid.Parse(c.Query("course_id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "course_id query param is required"})
	}
	modules, err := h.uc.GetModulesByCourse(c.Context(), courseID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"data": modules})
}

// POST /api/v1/academic/submissions — Student: submit work
func (h *AcademicHandler) SubmitWork(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	studentID, _ := uuid.Parse(claims.UserID)

	var sub domain.Submission
	if err := c.BodyParser(&sub); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}
	sub.StudentID = studentID

	if err := h.uc.SubmitWork(c.Context(), &sub); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(fiber.Map{"message": "submission uploaded", "data": sub})
}

// GET /api/v1/academic/submissions?module_id=xxx — Staff: view submissions
func (h *AcademicHandler) GetSubmissions(c *fiber.Ctx) error {
	moduleID, err := uuid.Parse(c.Query("module_id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "module_id query param is required"})
	}
	subs, err := h.uc.GetSubmissionsByModule(c.Context(), moduleID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"data": subs})
}

// POST /api/v1/academic/submissions/:id/grade — Staff: grade submission
func (h *AcademicHandler) GradeSubmission(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	gradedBy, _ := uuid.Parse(claims.UserID)
	submissionID, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid submission id"})
	}

	var body struct {
		Score float64 `json:"score"`
	}
	if err := c.BodyParser(&body); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}

	if err := h.uc.GradeSubmission(c.Context(), submissionID, body.Score, gradedBy); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "submission graded"})
}

// POST /api/v1/academic/assign-target — Staff/Admin: assign course/quiz to class/major/role/user
func (h *AcademicHandler) AssignTarget(c *fiber.Ctx) error {
	var target domain.AssignmentTarget
	if err := c.BodyParser(&target); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}
	if err := h.uc.AssignTarget(c.Context(), &target); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(fiber.Map{"message": "target assigned", "data": target})
}

// ==========================================
// SCHEDULES
// ==========================================

// GET /api/v1/academic/schedules/student/day/:dayOfWeek — Student: view their schedules
func (h *AcademicHandler) GetStudentSchedules(c *fiber.Ctx) error {
	claims := c.Locals("claims").(*middleware.Claims)
	studentID, _ := uuid.Parse(claims.UserID)
	tenantID, _ := uuid.Parse(claims.TenantID)

	dayOfWeek, err := c.ParamsInt("dayOfWeek")
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid dayOfWeek param"})
	}

	schedules, err := h.uc.GetStudentSchedules(c.Context(), tenantID, studentID, dayOfWeek)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(fiber.Map{"data": schedules})
}
