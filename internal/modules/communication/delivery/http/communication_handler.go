package http

import (
	"github.com/gofiber/fiber/v2"
)

type CommunicationHandler struct{}

func NewCommunicationHandler() *CommunicationHandler {
	return &CommunicationHandler{}
}

func (h *CommunicationHandler) GetAnnouncements(c *fiber.Ctx) error {
	return c.JSON(fiber.Map{"message": "GetAnnouncements endpoint stub"})
}
