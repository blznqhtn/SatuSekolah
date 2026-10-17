package services

import (
	"context"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/lms/entities"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/lms/requests"
)

type LmsService interface {
	CreateCourse(ctx context.Context, req *requests.CreateCourseRequest) (*entities.Course, error)
	CreateModule(ctx context.Context, req *requests.CreateModuleRequest) (*entities.Module, error)
	CreateQuiz(ctx context.Context, req *requests.CreateQuizRequest) (*entities.Quiz, error)
	CreateQuestion(ctx context.Context, req *requests.CreateQuestionRequest) (*entities.Question, error)
	SubmitAnswer(ctx context.Context, req *requests.SubmitAnswerRequest) (*entities.StudentAnswer, error)
}

type LibraryService interface {
	CreateBook(ctx context.Context, req *requests.CreateBookRequest) (*entities.Book, error)
	BorrowBook(ctx context.Context, req *requests.BorrowBookRequest) (*entities.BookBorrowing, error)
	ReturnBook(ctx context.Context, req *requests.ReturnBookRequest) (*entities.BookBorrowing, error)
	CreateEJournal(ctx context.Context, req *requests.CreateEJournalRequest) (*entities.EJournal, error)
}
