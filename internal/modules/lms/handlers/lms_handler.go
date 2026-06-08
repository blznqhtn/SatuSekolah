package handlers

import "github.com/gofiber/fiber/v2"

type LmsHandler interface {
	CreateCourse(c *fiber.Ctx) error
	CreateModule(c *fiber.Ctx) error
	CreateQuiz(c *fiber.Ctx) error
	CreateQuestion(c *fiber.Ctx) error
	SubmitAnswer(c *fiber.Ctx) error
}

type LibraryHandler interface {
	CreateBook(c *fiber.Ctx) error
	BorrowBook(c *fiber.Ctx) error
	ReturnBook(c *fiber.Ctx) error
	CreateEJournal(c *fiber.Ctx) error
}
