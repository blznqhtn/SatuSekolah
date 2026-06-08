package handlers

import "github.com/gofiber/fiber/v2"

type AttendanceHandler interface {
	CheckIn(c *fiber.Ctx) error
	CheckOut(c *fiber.Ctx) error
	RequestLeave(c *fiber.Ctx) error
	ApproveLeave(c *fiber.Ctx) error
}
