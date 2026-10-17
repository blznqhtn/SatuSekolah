package repository

import (
	"context"
	"database/sql"
	"fmt"
	"math/rand"
	"strings"
	"time"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/finance/domain"
)

type billingRepository struct {
	db *sql.DB
}

func NewBillingRepository(db *sql.DB) domain.BillingRepository {
	return &billingRepository{db: db}
}

// generateUniqueCode menghasilkan kode alfanumerik acak dengan panjang tertentu
func generateUniqueCode(length int) string {
	const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
	rand.New(rand.NewSource(time.Now().UnixNano()))
	b := make([]byte, length)
	for i := range b {
		b[i] = chars[rand.Intn(len(chars))]
	}
	return string(b)
}

// generateInvoiceVA menghasilkan virtual account 15 digit untuk tagihan:
// 12 digit accountNumber + 3 digit kode unik
func generateInvoiceVA(baseAccountNumber string) string {
	suffix := fmt.Sprintf("%03d", rand.Intn(1000))
	if len(baseAccountNumber) >= 12 {
		return baseAccountNumber[:12] + suffix
	}
	return baseAccountNumber + suffix
}

func (r *billingRepository) BatchInsertInvoices(ctx context.Context, invoices []*domain.StudentInvoice) error {
	if len(invoices) == 0 {
		return nil
	}

	cols := "id, tenant_id, student_id, fee_id, invoice_name, total_amount, status, can_installment, minimum_installment, dynamic_qr_code, rfid_payment_code, transfer_target_account, due_date"
	query := "INSERT INTO student_invoices (" + cols + ") VALUES "

	var values []interface{}
	var placeholders []string

	for _, inv := range invoices {
		placeholders = append(placeholders, "(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)")
		values = append(values,
			inv.ID,
			inv.TenantID,
			inv.StudentID,
			inv.FeeID,
			inv.InvoiceName,
			inv.TotalAmount,
			inv.Status,
			inv.CanInstallment,
			inv.MinimumInstallment,
			inv.DynamicQRCode,
			inv.RFIDPaymentCode,
			inv.TransferTargetAccount,
			inv.DueDate,
		)
	}

	query += strings.Join(placeholders, ", ")
	_, err := r.db.ExecContext(ctx, query, values...)
	return err
}

// scanInvoice membantu scan baris invoice dari SQL dengan semua kolom baru
func scanInvoice(row interface{ Scan(...interface{}) error }) (*domain.StudentInvoice, error) {
	var inv domain.StudentInvoice
	err := row.Scan(
		&inv.ID, &inv.TenantID, &inv.StudentID, &inv.FeeID,
		&inv.InvoiceName, &inv.TotalAmount, &inv.PaidAmount,
		&inv.Status, &inv.CanInstallment, &inv.MinimumInstallment,
		&inv.DynamicQRCode, &inv.RFIDPaymentCode, &inv.TransferTargetAccount,
		&inv.MidtransOrderID, &inv.DueDate, &inv.CreatedAt,
	)
	if err != nil {
		return nil, err
	}
	return &inv, nil
}

var invoiceSelectCols = `
	id, tenant_id, student_id, fee_id, invoice_name, total_amount, paid_amount,
	status, can_installment, minimum_installment,
	dynamic_qr_code, rfid_payment_code, transfer_target_account,
	midtrans_order_id, due_date, created_at
`

func (r *billingRepository) GetStudentInvoices(ctx context.Context, tenantID, studentID uuid.UUID) ([]*domain.StudentInvoice, error) {
	query := fmt.Sprintf(`SELECT %s FROM student_invoices WHERE tenant_id = ? AND student_id = ? AND deleted_at IS NULL ORDER BY created_at DESC`, invoiceSelectCols)
	rows, err := r.db.QueryContext(ctx, query, tenantID, studentID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var invoices []*domain.StudentInvoice
	for rows.Next() {
		inv, err := scanInvoice(rows)
		if err != nil {
			return nil, err
		}
		invoices = append(invoices, inv)
	}
	return invoices, nil
}

func (r *billingRepository) GetInvoiceByID(ctx context.Context, invoiceID uuid.UUID) (*domain.StudentInvoice, error) {
	query := fmt.Sprintf(`SELECT %s FROM student_invoices WHERE id = ?`, invoiceSelectCols)
	inv, err := scanInvoice(r.db.QueryRowContext(ctx, query, invoiceID))
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return inv, err
}

func (r *billingRepository) GetInvoiceByDynamicQR(ctx context.Context, qrCode string) (*domain.StudentInvoice, error) {
	query := fmt.Sprintf(`SELECT %s FROM student_invoices WHERE dynamic_qr_code = ?`, invoiceSelectCols)
	inv, err := scanInvoice(r.db.QueryRowContext(ctx, query, qrCode))
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return inv, err
}

func (r *billingRepository) GetInvoiceByRFIDCode(ctx context.Context, rfidCode string) (*domain.StudentInvoice, error) {
	query := fmt.Sprintf(`SELECT %s FROM student_invoices WHERE rfid_payment_code = ?`, invoiceSelectCols)
	inv, err := scanInvoice(r.db.QueryRowContext(ctx, query, rfidCode))
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return inv, err
}

func (r *billingRepository) GetInvoiceByTransferAccount(ctx context.Context, accountNumber string) (*domain.StudentInvoice, error) {
	query := fmt.Sprintf(`SELECT %s FROM student_invoices WHERE transfer_target_account = ?`, invoiceSelectCols)
	inv, err := scanInvoice(r.db.QueryRowContext(ctx, query, accountNumber))
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return inv, err
}

func (r *billingRepository) GetInvoiceByMidtransOrderID(ctx context.Context, orderID string) (*domain.StudentInvoice, error) {
	query := fmt.Sprintf(`SELECT %s FROM student_invoices WHERE midtrans_order_id = ?`, invoiceSelectCols)
	inv, err := scanInvoice(r.db.QueryRowContext(ctx, query, orderID))
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return inv, err
}

func (r *billingRepository) UpdateInvoiceStatus(ctx context.Context, invoiceID uuid.UUID, paidAmount float64, status string) error {
	query := `UPDATE student_invoices SET paid_amount = ?, status = ?, updated_at = NOW() WHERE id = ?`
	_, err := r.db.ExecContext(ctx, query, paidAmount, status, invoiceID)
	return err
}

func (r *billingRepository) UpdateInvoiceMidtransOrderID(ctx context.Context, invoiceID uuid.UUID, orderID string) error {
	query := `UPDATE student_invoices SET midtrans_order_id = ?, updated_at = NOW() WHERE id = ?`
	_, err := r.db.ExecContext(ctx, query, orderID, invoiceID)
	return err
}

func (r *billingRepository) RecordPayment(ctx context.Context, invoiceID, ledgerID uuid.UUID, amount float64) error {
	query := `INSERT INTO invoice_payments (id, invoice_id, wallet_ledger_id, paid_amount) VALUES (?, ?, ?, ?)`
	_, err := r.db.ExecContext(ctx, query, uuid.New(), invoiceID, ledgerID, amount)
	return err
}

func (r *billingRepository) GetStudentsByTarget(ctx context.Context, tenantID uuid.UUID, classID, majorID *uuid.UUID) ([]uuid.UUID, error) {
	query := `SELECT id FROM users WHERE tenant_id = ? AND category = 'student' AND deleted_at IS NULL`
	var args []interface{}
	args = append(args, tenantID)

	if classID != nil {
		query += ` AND class_id = ?`
		args = append(args, *classID)
	}
	if majorID != nil {
		query += ` AND class_id IN (SELECT id FROM classes WHERE major_id = ?)`
		args = append(args, *majorID)
	}

	rows, err := r.db.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var studentIDs []uuid.UUID
	for rows.Next() {
		var id uuid.UUID
		if err := rows.Scan(&id); err != nil {
			return nil, err
		}
		studentIDs = append(studentIDs, id)
	}
	return studentIDs, nil
}

func (r *billingRepository) GetFinanceReport(ctx context.Context, tenantID uuid.UUID, feeTypeID *uuid.UUID) ([]*domain.InvoicePaymentSummary, error) {
	query := `
		SELECT 
			si.student_id, u.name AS student_name, u.identifier AS nisn,
			si.invoice_name, si.total_amount, si.paid_amount, si.status, si.due_date
		FROM student_invoices si
		JOIN users u ON u.id = si.student_id
		WHERE si.tenant_id = ? AND si.deleted_at IS NULL
	`
	args := []interface{}{tenantID}

	if feeTypeID != nil {
		query += ` AND si.fee_id IN (SELECT id FROM fees WHERE fee_type_id = ?)`
		args = append(args, *feeTypeID)
	}
	query += ` ORDER BY si.created_at DESC`

	rows, err := r.db.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []*domain.InvoicePaymentSummary
	for rows.Next() {
		var s domain.InvoicePaymentSummary
		if err := rows.Scan(
			&s.StudentID, &s.StudentName, &s.NISN,
			&s.InvoiceName, &s.TotalAmount, &s.PaidAmount, &s.Status, &s.DueDate,
		); err != nil {
			return nil, err
		}
		results = append(results, &s)
	}
	return results, nil
}
