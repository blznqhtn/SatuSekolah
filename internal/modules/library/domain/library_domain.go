package domain

import (
	"context"
	"time"

	"github.com/google/uuid"
)

type BookType string

const (
	BookTypePhysical BookType = "PHYSICAL"
	BookTypeDigital  BookType = "DIGITAL"
)

type PaymentType string

const (
	PaymentTypeFree         PaymentType = "FREE"
	PaymentTypeOneTime      PaymentType = "ONE_TIME"
	PaymentTypeSubscription PaymentType = "SUBSCRIPTION"
)

type BorrowStatus string

const (
	BorrowPending  BorrowStatus = "PENDING"
	BorrowApproved BorrowStatus = "APPROVED"
	BorrowBorrowed BorrowStatus = "BORROWED"
	BorrowReturned BorrowStatus = "RETURNED"
	BorrowRejected BorrowStatus = "REJECTED"
	BorrowOverdue  BorrowStatus = "OVERDUE"
)

type JournalStatus string

const (
	JournalPending   JournalStatus = "PENDING"
	JournalApproved  JournalStatus = "APPROVED"
	JournalRejected  JournalStatus = "REJECTED"
)

// Library Settings (for dynamic roles like Archive Admin)
type LibrarySetting struct {
	TenantID            uuid.UUID  `json:"tenant_id"`
	ArchiveAdminStaffID *uuid.UUID `json:"archive_admin_staff_id"` // Who approves journals
	CreatedAt           time.Time  `json:"created_at"`
}

// Book represents physical and digital books
type Book struct {
	ID                uuid.UUID   `json:"id"`
	TenantID          uuid.UUID   `json:"tenant_id"`
	Title             string      `json:"title"`
	Author            string      `json:"author"`
	BookType          BookType    `json:"book_type"` // PHYSICAL or DIGITAL
	Stock             int         `json:"stock"`     // For PHYSICAL
	IsNegotiableTime  bool        `json:"is_negotiable_time"`
	MaxBorrowDays     int         `json:"max_borrow_days"`
	LateFeePerDay     float64     `json:"late_fee_per_day"` // For PHYSICAL
	PaymentType       PaymentType `json:"payment_type"`     // For DIGITAL
	Price             float64     `json:"price"`            // For DIGITAL
	UploaderStaffID   uuid.UUID   `json:"uploader_staff_id"`
	CreatedAt         time.Time   `json:"created_at"`
}

// BookBorrowing represents physical book borrowing cycle
type BookBorrowing struct {
	ID                 uuid.UUID    `json:"id"`
	TenantID           uuid.UUID    `json:"tenant_id"`
	UserID             uuid.UUID    `json:"user_id"`
	BookID             uuid.UUID    `json:"book_id"`
	RequestedStartDate time.Time    `json:"requested_start_date"`
	RequestedEndDate   time.Time    `json:"requested_end_date"`
	ApprovedStartDate  *time.Time   `json:"approved_start_date"`
	ApprovedEndDate    *time.Time   `json:"approved_end_date"`
	Status             BorrowStatus `json:"status"`
	BorrowQRToken      string       `json:"borrow_qr_token"`
	ReturnQRToken      string       `json:"return_qr_token"`
	ActualBorrowedAt   *time.Time   `json:"actual_borrowed_at"`
	ActualReturnedAt   *time.Time   `json:"actual_returned_at"`
	LateFeePaid        float64      `json:"late_fee_paid"`
	CreatedAt          time.Time    `json:"created_at"`
}

// JournalArchive represents SMK scientific journals
type JournalArchive struct {
	ID           uuid.UUID     `json:"id"`
	TenantID     uuid.UUID     `json:"tenant_id"`
	UploaderID   uuid.UUID     `json:"uploader_id"`
	Title        string        `json:"title"`
	Abstract     string        `json:"abstract"`
	Angkatan     int           `json:"angkatan"`
	Kelas        string        `json:"kelas"`
	Jurusan      string        `json:"jurusan"`
	SoftcopyURL  string        `json:"softcopy_url"`
	ScannerURL   string        `json:"scanner_url"`
	Status       JournalStatus `json:"status"`
	ApprovedBy   *uuid.UUID    `json:"approved_by"`
	CreatedAt    time.Time     `json:"created_at"`
}

// Interfaces

type LibraryRepository interface {
	GetSetting(ctx context.Context, tenantID uuid.UUID) (*LibrarySetting, error)
	UpsertSetting(ctx context.Context, setting *LibrarySetting) error

	CreateBook(ctx context.Context, book *Book) error
	GetBook(ctx context.Context, bookID uuid.UUID) (*Book, error)
	UpdateBookStock(ctx context.Context, bookID uuid.UUID, delta int) error

	CreateBorrowing(ctx context.Context, borrowing *BookBorrowing) error
	GetBorrowing(ctx context.Context, borrowingID uuid.UUID) (*BookBorrowing, error)
	UpdateBorrowing(ctx context.Context, borrowing *BookBorrowing) error

	CreateJournal(ctx context.Context, journal *JournalArchive) error
	GetJournal(ctx context.Context, journalID uuid.UUID) (*JournalArchive, error)
	UpdateJournalStatus(ctx context.Context, journalID uuid.UUID, status JournalStatus, approvedBy uuid.UUID) error
}

type LibraryUsecase interface {
	// Settings
	ConfigureSetting(ctx context.Context, setting *LibrarySetting, adminID uuid.UUID) error
	
	// Books
	AddBook(ctx context.Context, book *Book, staffID uuid.UUID) error
	
	// Physical Borrowing Flow
	RequestBorrow(ctx context.Context, req *BookBorrowing) error
	ApproveBorrow(ctx context.Context, borrowingID uuid.UUID, staffID uuid.UUID, approvedStartDate, approvedEndDate time.Time) error
	ScanBorrowQR(ctx context.Context, borrowingID uuid.UUID, staffID uuid.UUID) error
	
	// Return Flow (Checks for fee, returns destination account_number for PIN payment)
	CheckReturnScan(ctx context.Context, borrowingID uuid.UUID, staffID uuid.UUID) (fee float64, requiresPIN bool, staffAccountNumber string, err error)
	ConfirmReturnScan(ctx context.Context, borrowingID uuid.UUID, staffID uuid.UUID, pin string) error

	// Digital Purchase
	PurchaseDigitalBook(ctx context.Context, bookID uuid.UUID, userID uuid.UUID, pin string) error

	// Journals
	UploadJournal(ctx context.Context, journal *JournalArchive) error
	ApproveJournal(ctx context.Context, journalID uuid.UUID, staffID uuid.UUID) error
}
