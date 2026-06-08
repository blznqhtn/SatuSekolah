package handlers

import "github.com/gofiber/fiber/v2"

type CbaHandler interface {
	CreateCompany(c *fiber.Ctx) error
	CreateJobVacancy(c *fiber.Ctx) error
	ApplyJob(c *fiber.Ctx) error
}
