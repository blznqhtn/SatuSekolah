package handlers

import "github.com/gofiber/fiber/v2"

type AcademicYearHandler interface {
	CreateAcademicYear(c *fiber.Ctx) error
}

type MajorHandler interface {
	CreateMajor(c *fiber.Ctx) error
}

type ClassHandler interface {
	CreateClass(c *fiber.Ctx) error
}
// ... and so on for other academic entities
