package handlers

import "github.com/gofiber/fiber/v2"

type WalletHandler interface {
	GetWalletByUserID(c *fiber.Ctx) error
	TopUp(c *fiber.Ctx) error
	Withdraw(c *fiber.Ctx) error
}

type FeeHandler interface {
	CreateFee(c *fiber.Ctx) error
}

type InvoiceHandler interface {
	CreateInvoice(c *fiber.Ctx) error
	PayInvoice(c *fiber.Ctx) error
}

type ReimbursementHandler interface {
	CreateReimbursement(c *fiber.Ctx) error
}
