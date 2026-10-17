package handlers

import "github.com/gofiber/fiber/v2"

type TenantHandler interface {
	CreateTenant(c *fiber.Ctx) error
	GetTenantByID(c *fiber.Ctx) error
	// Add other handler methods here
}
