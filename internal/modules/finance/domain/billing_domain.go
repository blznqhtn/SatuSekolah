package domain

import (
	"context"
	"time"

	"github.com/google/uuid"
)

// FeeType adalah kategori tagihan (contoh: SPP, Uang Kegiatan, SPMB)
type FeeType struct {
	ID           uuid.UUID  `json:"id"`
	TenantID     uuid.UUID  `json:"tenant_id"`
	Name         string     `json:"name"`
	BillingCycle string     `json:"billing_cycle"` // e.g. "MONTHLY", "ONE_TIME"
	CreatedAt    time.Time  `json:"created_at"`
	UpdatedAt    *time.Time `json:"updated_at"`
}

// Fee adalah nominal tagihan untuk kelas/jurusan tertentu
type Fee struct {
	ID                 uuid.UUID  `json:"id"`
	FeeTypeID          uuid.UUID  `json:"fee_type_id"`
	MajorID            *uuid.UUID `json:"major_id"`
	GradeLevel         *int       `json:"grade_level"`
	Amount             float64    `json:"amount"`
	CanInstallment     bool       `json:"can_installment"`     // Apakah bisa dicicil
	MinimumInstallment float64    `json:"minimum_installment"` // Minimum nominal cicilan (0 = bebas)
	CreatedAt          time.Time  `json:"created_at"`
	UpdatedAt          *time.Time `json:"updated_at"`
}

// StudentInvoice adalah tagihan per siswa
type StudentInvoice struct {
	ID          uuid.UUID  `json:"id"`
	TenantID    uuid.UUID  `json:"tenant_id"`
	StudentID   uuid.UUID  `json:"student_id"`
	FeeID       uuid.UUID  `json:"fee_id"`
	InvoiceName string     `json:"invoice_name"`
	TotalAmount float64    `json:"total_amount"`
	PaidAmount  float64    `json:"paid_amount"`
	// Status: PENDING, PARTIAL (dicicil), PAID (lunas), EXPIRED (kedaluwarsa)
	Status             string     `json:"status"`
	CanInstallment     bool       `json:"can_installment"`
	MinimumInstallment float64    `json:"minimum_installment"`
	// Kode pembayaran dinamis (valid s.d. due_date)
	DynamicQRCode         *string    `json:"dynamic_qr_code,omitempty"`
	RFIDPaymentCode       *string    `json:"rfid_payment_code,omitempty"`
	TransferTargetAccount *string    `json:"transfer_target_account,omitempty"`
	// Midtrans order ID untuk pembayaran tunai oleh admin keuangan
	MidtransOrderID *string    `json:"midtrans_order_id,omitempty"`
	DueDate         *time.Time `json:"due_date"`
	CreatedAt       time.Time  `json:"created_at"`
	UpdatedAt       *time.Time `json:"updated_at"`
	// Data join (untuk laporan)
	StudentName string `json:"student_name,omitempty"`
	NISN        string `json:"nisn,omitempty"` // identifier di tabel users
}

// GenerateInvoiceRequest adalah payload permintaan pembuatan tagihan massal
type GenerateInvoiceRequest struct {
	FeeTypeID          uuid.UUID  `json:"fee_type_id"`
	InvoiceName        string     `json:"invoice_name"`
	Amount             float64    `json:"amount"`
	TargetClass        *uuid.UUID `json:"target_class_id"`
	TargetMajor        *uuid.UUID `json:"target_major_id"`
	DueDate            *time.Time `json:"due_date"`
	CanInstallment     bool       `json:"can_installment"`
	MinimumInstallment float64    `json:"minimum_installment"`
}

// InvoicePaymentSummary adalah ringkasan per siswa untuk laporan keuangan
type InvoicePaymentSummary struct {
	StudentID   uuid.UUID  `json:"student_id"`
	StudentName string     `json:"student_name"`
	NISN        string     `json:"nisn"`
	InvoiceName string     `json:"invoice_name"`
	TotalAmount float64    `json:"total_amount"`
	PaidAmount  float64    `json:"paid_amount"`
	Status      string     `json:"status"`
	DueDate     *time.Time `json:"due_date"`
}

// CashPaymentResponse adalah response dari pembuatan link Midtrans tunai
type CashPaymentResponse struct {
	SnapToken   string  `json:"snap_token"`
	SnapURL     string  `json:"snap_url"`
	OrderID     string  `json:"order_id"`
	TotalAmount float64 `json:"total_amount"` // Tagihan + 5000 admin fee
}

// BillingRepository mendefinisikan operasi database untuk Billing
type BillingRepository interface {
	BatchInsertInvoices(ctx context.Context, invoices []*StudentInvoice) error
	GetStudentInvoices(ctx context.Context, tenantID, studentID uuid.UUID) ([]*StudentInvoice, error)
	GetInvoiceByID(ctx context.Context, invoiceID uuid.UUID) (*StudentInvoice, error)
	GetInvoiceByDynamicQR(ctx context.Context, qrCode string) (*StudentInvoice, error)
	GetInvoiceByRFIDCode(ctx context.Context, rfidCode string) (*StudentInvoice, error)
	GetInvoiceByTransferAccount(ctx context.Context, accountNumber string) (*StudentInvoice, error)
	GetInvoiceByMidtransOrderID(ctx context.Context, orderID string) (*StudentInvoice, error)
	UpdateInvoiceStatus(ctx context.Context, invoiceID uuid.UUID, paidAmount float64, status string) error
	UpdateInvoiceMidtransOrderID(ctx context.Context, invoiceID uuid.UUID, orderID string) error
	RecordPayment(ctx context.Context, invoiceID, ledgerID uuid.UUID, amount float64) error
	GetStudentsByTarget(ctx context.Context, tenantID uuid.UUID, classID, majorID *uuid.UUID) ([]uuid.UUID, error)
	GetFinanceReport(ctx context.Context, tenantID uuid.UUID, feeTypeID *uuid.UUID) ([]*InvoicePaymentSummary, error)
}

// BillingUsecase mendefinisikan logika bisnis untuk Billing
type BillingUsecase interface {
	// Admin Keuangan: buat tagihan massal
	GenerateMassInvoices(ctx context.Context, tenantID uuid.UUID, req GenerateInvoiceRequest) error

	// Siswa / Orang Tua: lihat tagihan
	GetStudentInvoices(ctx context.Context, tenantID, studentID uuid.UUID) ([]*StudentInvoice, error)

	// Pembayaran via QR Dinamis (scan by pembeli)
	PayInvoiceDynamicQR(ctx context.Context, payerID uuid.UUID, qrCode string, amount float64, pin string) error

	// Pembayaran via IoT (RFID)
	GetInvoiceForIoT(ctx context.Context, rfidCode string) (*StudentInvoice, error)
	PayInvoiceRFID(ctx context.Context, rfidCode, rfidTag, pin string, amount float64) error

	// Pembayaran via Saldo / Transfer (ditangani TransferP2P di LedgerUsecase)

	// Pembayaran Tunai via Midtrans (oleh Admin Keuangan)
	InitiateCashPayment(ctx context.Context, adminID, invoiceID uuid.UUID, amount float64) (*CashPaymentResponse, error)
	ProcessMidtransWebhook(ctx context.Context, orderID, transactionStatus, grossAmount, signatureKey string) error

	// Laporan Keuangan Sekolah
	GetFinanceReport(ctx context.Context, tenantID uuid.UUID, feeTypeID *uuid.UUID) ([]*InvoicePaymentSummary, error)
}
