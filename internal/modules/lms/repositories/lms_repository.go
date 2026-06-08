package repositories

import (
	"context"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/lms/entities"
)

type CourseRepository interface {
	Save(ctx context.Context, course *entities.Course) error
}

type ModuleRepository interface {
	Save(ctx context.Context, module *entities.Module) error
}

type QuizRepository interface {
	Save(ctx context.Context, quiz *entities.Quiz) error
}

type QuestionRepository interface {
	Save(ctx context.Context, question *entities.Question) error
}

type StudentAnswerRepository interface {
	Save(ctx context.Context, answer *entities.StudentAnswer) error
}

type BookRepository interface {
	Save(ctx context.Context, book *entities.Book) error
}

type BookBorrowingRepository interface {
	Save(ctx context.Context, bb *entities.BookBorrowing) error
	Update(ctx context.Context, bb *entities.BookBorrowing) error
}

type EJournalRepository interface {
	Save(ctx context.Context, ej *entities.EJournal) error
}
