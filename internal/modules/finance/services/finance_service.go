package services

import (
	"context"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/finance/entities"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/finance/requests"
)

type WalletService interface {
	GetLedgersByUserID(ctx context.Context, userID string) ([]*entities.WalletLedger, error)
	ProcessTransaction(ctx context.Context, req *requests.ProcessTransactionRequest) (*entities.WalletLedger, error)
}

type FeeService interface {
	CreateFee(ctx context.Context, req *requests.CreateFeeRequest) (*entities.Fee, error)
}

type InvoiceService interface {
	CreateInvoice(ctx context.Context, req *requests.CreateInvoiceRequest) (*entities.StudentInvoice, error)
	ProcessPayment(ctx context.Context, req *requests.ProcessPaymentRequest) (*entities.StudentInvoice, error)
}

type ReimbursementService interface {
	CreateReimbursement(ctx context.Context, req *requests.CreateReimbursementRequest) (*entities.Reimbursement, error)
}
