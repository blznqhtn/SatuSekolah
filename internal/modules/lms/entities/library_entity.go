package entities

import (
	"database/sql"
	"time"

	"github.com/google/uuid"
)

type BorrowingStatus string

const (
	BorrowingPending  BorrowingStatus = "PENDING"
	BorrowingApproved BorrowingStatus = "APPROVED"
	Borrowed          BorrowingStatus = "BORROWED"
	Returned          BorrowingStatus = "RETURNED"
	BorrowingRejected BorrowingStatus = "REJECTED"
	Overdue           BorrowingStatus = "OVERDUE"
)

type JournalStatus string

const (
	JournalPending  JournalStatus = "PENDING"
	Published       JournalStatus = "PUBLISHED"
	JournalRejected JournalStatus = "REJECTED"
)

type Book struct {
	ID        uuid.UUID    `json:"id"`
	TenantID  uuid.UUID    `json:"tenant_id"`
	Title     string       `json:"title"`
	Author    string       `json:"author"`
	ISBN      string       `json:"isbn"`
	CoverURL  string       `json:"cover_url"`
	FileURL   string       `json:"file_url"`
	Stock     int          `json:"stock"`
	IsDigital bool         `json:"is_digital"`
	CreatedAt time.Time    `json:"created_at"`
	UpdatedAt sql.NullTime `json:"updated_at"`
	DeletedAt sql.NullTime `json:"deleted_at"`
}

type BookBorrowing struct {
	ID           uuid.UUID       `json:"id"`
	BookID       uuid.UUID       `json:"book_id"`
	UserID       uuid.UUID       `json:"user_id"`
	QRCodeToken  string          `json:"qr_code_token"`
	BorrowDate   time.Time       `json:"borrow_date"`
	PickupDate   sql.NullTime    `json:"pickup_date"`
	ReturnDate   time.Time       `json:"return_date"`
	Status       BorrowingStatus `json:"status"`
	ApprovedBy   uuid.UUID       `json:"approved_by"`
	CreatedAt    time.Time       `json:"created_at"`
	UpdatedAt    sql.NullTime    `json:"updated_at"`
}

type EJournal struct {
	ID             uuid.UUID     `json:"id"`
	TenantID       uuid.UUID     `json:"tenant_id"`
	StudentID      uuid.UUID     `json:"student_id"`
	AcademicYearID uuid.UUID     `json:"academic_year_id"`
	ClassID        uuid.UUID     `json:"class_id"`
	Title          string        `json:"title"`
	Description    string        `json:"description"`
	FileURL        string        `json:"file_url"`
	Status         JournalStatus `json:"status"`
	ApprovedBy     uuid.UUID     `json:"approved_by"`
	CreatedAt      time.Time     `json:"created_at"`
	UpdatedAt      sql.NullTime  `json:"updated_at"`
	DeletedAt      sql.NullTime  `json:"deleted_at"`
}
