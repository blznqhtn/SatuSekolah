package usecase

import (
	"context"
	"errors"
	"math"
	"time"

	"github.com/google/uuid"
	coreDomain "neuracakrawira.asia/satu-sekolah-backend/internal/modules/core/domain"
	financeDomain "neuracakrawira.asia/satu-sekolah-backend/internal/modules/finance/domain"
	libDomain "neuracakrawira.asia/satu-sekolah-backend/internal/modules/library/domain"
)

type libraryUsecase struct {
	repo      libDomain.LibraryRepository
	coreRepo  coreDomain.CoreRepository
	financeUc financeDomain.LedgerUsecase
}

func NewLibraryUsecase(repo libDomain.LibraryRepository, coreRepo coreDomain.CoreRepository, financeUc financeDomain.LedgerUsecase) libDomain.LibraryUsecase {
	return &libraryUsecase{repo: repo, coreRepo: coreRepo, financeUc: financeUc}
}

func (u *libraryUsecase) ConfigureSetting(ctx context.Context, setting *libDomain.LibrarySetting, adminID uuid.UUID) error {
	user, err := u.coreRepo.GetUserByID(ctx, adminID)
	if err != nil || user.Category != "admin" {
		return errors.New("unauthorized: only admin can configure library settings")
	}
	setting.TenantID = user.TenantID
	setting.CreatedAt = time.Now()
	return u.repo.UpsertSetting(ctx, setting)
}

func (u *libraryUsecase) AddBook(ctx context.Context, book *libDomain.Book, staffID uuid.UUID) error {
	book.UploaderStaffID = staffID
	return u.repo.CreateBook(ctx, book)
}

func (u *libraryUsecase) RequestBorrow(ctx context.Context, req *libDomain.BookBorrowing) error {
	book, err := u.repo.GetBook(ctx, req.BookID)
	if err != nil {
		return errors.New("book not found")
	}
	if book.BookType != libDomain.BookTypePhysical {
		return errors.New("only physical books can be borrowed")
	}
	if book.Stock <= 0 {
		return errors.New("book is out of stock")
	}
	
	req.Status = libDomain.BorrowPending
	return u.repo.CreateBorrowing(ctx, req)
}

func (u *libraryUsecase) ApproveBorrow(ctx context.Context, borrowingID uuid.UUID, staffID uuid.UUID, approvedStartDate, approvedEndDate time.Time) error {
	bw, err := u.repo.GetBorrowing(ctx, borrowingID)
	if err != nil {
		return err
	}
	book, _ := u.repo.GetBook(ctx, bw.BookID)
	
	if !book.IsNegotiableTime {
		days := approvedEndDate.Sub(approvedStartDate).Hours() / 24
		if days > float64(book.MaxBorrowDays) {
			return errors.New("exceeded maximum borrow days for non-negotiable book")
		}
	}

	bw.ApprovedStartDate = &approvedStartDate
	bw.ApprovedEndDate = &approvedEndDate
	bw.Status = libDomain.BorrowApproved
	bw.BorrowQRToken = uuid.New().String()
	bw.ReturnQRToken = uuid.New().String()
	
	return u.repo.UpdateBorrowing(ctx, bw)
}

func (u *libraryUsecase) ScanBorrowQR(ctx context.Context, borrowingID uuid.UUID, staffID uuid.UUID) error {
	bw, err := u.repo.GetBorrowing(ctx, borrowingID)
	if err != nil || bw.Status != libDomain.BorrowApproved {
		return errors.New("invalid borrowing state")
	}
	
	// Deduct stock
	if err := u.repo.UpdateBookStock(ctx, bw.BookID, -1); err != nil {
		return err
	}
	
	now := time.Now()
	bw.ActualBorrowedAt = &now
	bw.Status = libDomain.BorrowBorrowed
	return u.repo.UpdateBorrowing(ctx, bw)
}

func (u *libraryUsecase) CheckReturnScan(ctx context.Context, borrowingID uuid.UUID, staffID uuid.UUID) (float64, bool, string, error) {
	bw, err := u.repo.GetBorrowing(ctx, borrowingID)
	if err != nil || bw.Status != libDomain.BorrowBorrowed {
		return 0, false, "", errors.New("invalid borrowing state")
	}
	
	book, _ := u.repo.GetBook(ctx, bw.BookID)
	now := time.Now()
	
	var fee float64 = 0
	if now.After(*bw.ApprovedEndDate) {
		daysLate := math.Ceil(now.Sub(*bw.ApprovedEndDate).Hours() / 24)
		fee = daysLate * book.LateFeePerDay
	}
	
	if fee > 0 {
		// Fetch librarian's account number to display in the payment popup
		staff, err := u.coreRepo.GetUserByID(ctx, staffID)
		if err != nil || staff == nil {
			return 0, false, "", errors.New("librarian not found")
		}
		return fee, true, staff.AccountNumber, nil
	}
	
	// If no fee, we can process return directly
	if err := u.processReturn(ctx, bw, 0); err != nil {
		return 0, false, "", err
	}
	return 0, false, "", nil
}

func (u *libraryUsecase) ConfirmReturnScan(ctx context.Context, borrowingID uuid.UUID, staffID uuid.UUID, pin string) error {
	bw, err := u.repo.GetBorrowing(ctx, borrowingID)
	if err != nil || bw.Status != libDomain.BorrowBorrowed {
		return errors.New("invalid borrowing state")
	}
	
	book, _ := u.repo.GetBook(ctx, bw.BookID)
	now := time.Now()
	
	var fee float64 = 0
	if now.After(*bw.ApprovedEndDate) {
		daysLate := math.Ceil(now.Sub(*bw.ApprovedEndDate).Hours() / 24)
		fee = daysLate * book.LateFeePerDay
	}
	
	if fee > 0 {
		user, err := u.coreRepo.GetUserByID(ctx, bw.UserID)
		if err != nil {
			return errors.New("user not found")
		}
		// PIN Verification should be done here in a real scenario (e.g. bcrypt.CompareHashAndPassword)
		if user.PinHash == "" {
			return errors.New("pin not set for user")
		}

		if err := u.financeUc.InternalTransfer(ctx, bw.TenantID, bw.UserID, staffID, fee); err != nil {
			return errors.New("failed to process late fee: " + err.Error())
		}
	}
	
	return u.processReturn(ctx, bw, fee)
}

func (u *libraryUsecase) processReturn(ctx context.Context, bw *libDomain.BookBorrowing, feePaid float64) error {
	now := time.Now()
	bw.ActualReturnedAt = &now
	bw.Status = libDomain.BorrowReturned
	bw.LateFeePaid = feePaid
	
	if err := u.repo.UpdateBorrowing(ctx, bw); err != nil {
		return err
	}
	return u.repo.UpdateBookStock(ctx, bw.BookID, 1)
}

func (u *libraryUsecase) PurchaseDigitalBook(ctx context.Context, bookID uuid.UUID, userID uuid.UUID, pin string) error {
	book, err := u.repo.GetBook(ctx, bookID)
	if err != nil || book.BookType != libDomain.BookTypeDigital {
		return errors.New("invalid digital book")
	}
	if book.PaymentType == libDomain.PaymentTypeFree {
		return nil // Access granted immediately
	}
	
	user, err := u.coreRepo.GetUserByID(ctx, userID)
	if err != nil {
		return errors.New("user not found")
	}
	// PIN Verification should be done here in a real scenario (e.g. bcrypt.CompareHashAndPassword)
	if user.PinHash == "" {
		return errors.New("pin not set for user")
	}

	if err := u.financeUc.InternalTransfer(ctx, book.TenantID, userID, book.UploaderStaffID, book.Price); err != nil {
		return err
	}
	return nil
}

func (u *libraryUsecase) UploadJournal(ctx context.Context, journal *libDomain.JournalArchive) error {
	journal.Status = libDomain.JournalPending
	return u.repo.CreateJournal(ctx, journal)
}

func (u *libraryUsecase) ApproveJournal(ctx context.Context, journalID uuid.UUID, staffID uuid.UUID) error {
	j, err := u.repo.GetJournal(ctx, journalID)
	if err != nil {
		return err
	}
	
	setting, _ := u.repo.GetSetting(ctx, j.TenantID)
	if setting == nil || setting.ArchiveAdminStaffID == nil || *setting.ArchiveAdminStaffID != staffID {
		return errors.New("unauthorized: only archive admin can approve journals")
	}
	
	return u.repo.UpdateJournalStatus(ctx, journalID, libDomain.JournalApproved, staffID)
}
