package repository

import (
	"context"
	"database/sql"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/library/domain"
)

type libraryRepository struct {
	db *sql.DB
}

func NewLibraryRepository(db *sql.DB) domain.LibraryRepository {
	return &libraryRepository{db: db}
}

func (r *libraryRepository) GetSetting(ctx context.Context, tenantID uuid.UUID) (*domain.LibrarySetting, error) {
	var s domain.LibrarySetting
	err := r.db.QueryRowContext(ctx, "SELECT tenant_id, archive_admin_staff_id, created_at FROM library_settings WHERE tenant_id = ?", tenantID).
		Scan(&s.TenantID, &s.ArchiveAdminStaffID, &s.CreatedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return &s, err
}

func (r *libraryRepository) UpsertSetting(ctx context.Context, s *domain.LibrarySetting) error {
	_, err := r.db.ExecContext(ctx, `
		INSERT INTO library_settings (tenant_id, archive_admin_staff_id, created_at) 
		VALUES (?, ?, ?)
		ON DUPLICATE KEY UPDATE archive_admin_staff_id = VALUES(archive_admin_staff_id)
	`, s.TenantID, s.ArchiveAdminStaffID, s.CreatedAt)
	return err
}

func (r *libraryRepository) CreateBook(ctx context.Context, b *domain.Book) error {
	if b.ID == uuid.Nil {
		b.ID = uuid.New()
	}
	_, err := r.db.ExecContext(ctx, `
		INSERT INTO books (id, tenant_id, title, author, book_type, stock, is_negotiable_time, max_borrow_days, late_fee_per_day, payment_type, price, uploader_staff_id)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
	`, b.ID, b.TenantID, b.Title, b.Author, b.BookType, b.Stock, b.IsNegotiableTime, b.MaxBorrowDays, b.LateFeePerDay, b.PaymentType, b.Price, b.UploaderStaffID)
	return err
}

func (r *libraryRepository) GetBook(ctx context.Context, bookID uuid.UUID) (*domain.Book, error) {
	var b domain.Book
	err := r.db.QueryRowContext(ctx, `
		SELECT id, tenant_id, title, author, book_type, stock, is_negotiable_time, max_borrow_days, late_fee_per_day, payment_type, price, uploader_staff_id, created_at
		FROM books WHERE id = ?
	`, bookID).Scan(&b.ID, &b.TenantID, &b.Title, &b.Author, &b.BookType, &b.Stock, &b.IsNegotiableTime, &b.MaxBorrowDays, &b.LateFeePerDay, &b.PaymentType, &b.Price, &b.UploaderStaffID, &b.CreatedAt)
	if err != nil {
		return nil, err
	}
	return &b, nil
}

func (r *libraryRepository) UpdateBookStock(ctx context.Context, bookID uuid.UUID, delta int) error {
	_, err := r.db.ExecContext(ctx, "UPDATE books SET stock = stock + ? WHERE id = ?", delta, bookID)
	return err
}

func (r *libraryRepository) CreateBorrowing(ctx context.Context, bw *domain.BookBorrowing) error {
	if bw.ID == uuid.Nil {
		bw.ID = uuid.New()
	}
	_, err := r.db.ExecContext(ctx, `
		INSERT INTO book_borrowings (id, tenant_id, user_id, book_id, requested_start_date, requested_end_date, status)
		VALUES (?, ?, ?, ?, ?, ?, ?)
	`, bw.ID, bw.TenantID, bw.UserID, bw.BookID, bw.RequestedStartDate, bw.RequestedEndDate, bw.Status)
	return err
}

func (r *libraryRepository) GetBorrowing(ctx context.Context, borrowingID uuid.UUID) (*domain.BookBorrowing, error) {
	var bw domain.BookBorrowing
	err := r.db.QueryRowContext(ctx, `
		SELECT id, tenant_id, user_id, book_id, requested_start_date, requested_end_date, approved_start_date, approved_end_date, status, borrow_qr_token, return_qr_token, actual_borrowed_at, actual_returned_at, late_fee_paid, created_at
		FROM book_borrowings WHERE id = ?
	`, borrowingID).Scan(&bw.ID, &bw.TenantID, &bw.UserID, &bw.BookID, &bw.RequestedStartDate, &bw.RequestedEndDate, &bw.ApprovedStartDate, &bw.ApprovedEndDate, &bw.Status, &bw.BorrowQRToken, &bw.ReturnQRToken, &bw.ActualBorrowedAt, &bw.ActualReturnedAt, &bw.LateFeePaid, &bw.CreatedAt)
	if err != nil {
		return nil, err
	}
	return &bw, nil
}

func (r *libraryRepository) UpdateBorrowing(ctx context.Context, bw *domain.BookBorrowing) error {
	_, err := r.db.ExecContext(ctx, `
		UPDATE book_borrowings SET approved_start_date=?, approved_end_date=?, status=?, borrow_qr_token=?, return_qr_token=?, actual_borrowed_at=?, actual_returned_at=?, late_fee_paid=? 
		WHERE id = ?
	`, bw.ApprovedStartDate, bw.ApprovedEndDate, bw.Status, bw.BorrowQRToken, bw.ReturnQRToken, bw.ActualBorrowedAt, bw.ActualReturnedAt, bw.LateFeePaid, bw.ID)
	return err
}

func (r *libraryRepository) CreateJournal(ctx context.Context, j *domain.JournalArchive) error {
	if j.ID == uuid.Nil {
		j.ID = uuid.New()
	}
	_, err := r.db.ExecContext(ctx, `
		INSERT INTO scientific_journals (id, tenant_id, uploader_id, title, abstract, angkatan, kelas, jurusan, softcopy_url, scanner_url, status)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
	`, j.ID, j.TenantID, j.UploaderID, j.Title, j.Abstract, j.Angkatan, j.Kelas, j.Jurusan, j.SoftcopyURL, j.ScannerURL, j.Status)
	return err
}

func (r *libraryRepository) GetJournal(ctx context.Context, journalID uuid.UUID) (*domain.JournalArchive, error) {
	var j domain.JournalArchive
	err := r.db.QueryRowContext(ctx, `
		SELECT id, tenant_id, uploader_id, title, abstract, angkatan, kelas, jurusan, softcopy_url, scanner_url, status, approved_by, created_at
		FROM scientific_journals WHERE id = ?
	`, journalID).Scan(&j.ID, &j.TenantID, &j.UploaderID, &j.Title, &j.Abstract, &j.Angkatan, &j.Kelas, &j.Jurusan, &j.SoftcopyURL, &j.ScannerURL, &j.Status, &j.ApprovedBy, &j.CreatedAt)
	if err != nil {
		return nil, err
	}
	return &j, nil
}

func (r *libraryRepository) UpdateJournalStatus(ctx context.Context, journalID uuid.UUID, status domain.JournalStatus, approvedBy uuid.UUID) error {
	_, err := r.db.ExecContext(ctx, "UPDATE scientific_journals SET status=?, approved_by=? WHERE id=?", status, approvedBy, journalID)
	return err
}
