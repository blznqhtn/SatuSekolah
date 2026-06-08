package repositories

import (
	"context"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/finance/entities"
)

type WalletLedgerRepository interface {
	Save(ctx context.Context, wl *entities.WalletLedger) error
	FindByUserID(ctx context.Context, userID string) ([]*entities.WalletLedger, error)
}

type FeeRepository interface {
	Save(ctx context.Context, f *entities.Fee) error
}

type InvoiceRepository interface {
	Save(ctx context.Context, i *entities.StudentInvoice) error
	Update(ctx context.Context, i *entities.StudentInvoice) error
}

type ReimbursementRepository interface {
	Save(ctx context.Context, r *entities.Reimbursement) error
}
