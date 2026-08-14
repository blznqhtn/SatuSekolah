package repository

import (
	"context"
	"database/sql"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/payment/domain"
)

type paymentRepository struct {
	db *sql.DB
}

func NewPaymentRepository(db *sql.DB) domain.PaymentRepository {
	return &paymentRepository{db: db}
}

func (r *paymentRepository) GetActiveBills(ctx context.Context, tenantID, studentID uuid.UUID) ([]*domain.PaymentBill, error) {
	query := `
		SELECT b.id, b.tenant_id, b.student_id, b.category_id, b.title, b.total_amount, b.paid_amount, b.status, b.due_date, b.created_at, b.updated_at,
		       c.name
		FROM payment_bills b
		LEFT JOIN payment_categories c ON b.category_id = c.id
		WHERE b.tenant_id = ? AND b.student_id = ? AND b.status = 'PENDING'
		ORDER BY b.due_date ASC
	`
	rows, err := r.db.QueryContext(ctx, query, tenantID, studentID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var bills []*domain.PaymentBill
	for rows.Next() {
		var b domain.PaymentBill
		var cName sql.NullString
		if err := rows.Scan(
			&b.ID, &b.TenantID, &b.StudentID, &b.CategoryID, &b.Title, &b.TotalAmount, &b.PaidAmount, &b.Status, &b.DueDate, &b.CreatedAt, &b.UpdatedAt,
			&cName,
		); err != nil {
			return nil, err
		}
		if cName.Valid {
			b.Category = &domain.PaymentCategory{
				ID:   b.CategoryID,
				Name: cName.String,
			}
		}
		bills = append(bills, &b)
	}
	return bills, nil
}

func (r *paymentRepository) GetBillDetails(ctx context.Context, billID uuid.UUID) ([]*domain.PaymentBillDetail, error) {
	query := `SELECT id, bill_id, item_name, amount, is_deduction FROM payment_bill_details WHERE bill_id = ?`
	rows, err := r.db.QueryContext(ctx, query, billID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var details []*domain.PaymentBillDetail
	for rows.Next() {
		var d domain.PaymentBillDetail
		if err := rows.Scan(&d.ID, &d.BillID, &d.ItemName, &d.Amount, &d.IsDeduction); err != nil {
			return nil, err
		}
		details = append(details, &d)
	}
	return details, nil
}

func (r *paymentRepository) GetTransactions(ctx context.Context, tenantID, studentID uuid.UUID) ([]*domain.PaymentTransaction, error) {
	query := `
		SELECT t.id, t.tenant_id, t.bill_id, t.student_id, t.amount, t.payment_method, t.reference_no, t.status, t.paid_at, t.created_at,
		       b.title
		FROM payment_transactions t
		JOIN payment_bills b ON t.bill_id = b.id
		WHERE t.tenant_id = ? AND t.student_id = ?
		ORDER BY t.created_at DESC
	`
	rows, err := r.db.QueryContext(ctx, query, tenantID, studentID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var trxs []*domain.PaymentTransaction
	for rows.Next() {
		var t domain.PaymentTransaction
		if err := rows.Scan(
			&t.ID, &t.TenantID, &t.BillID, &t.StudentID, &t.Amount, &t.PaymentMethod, &t.ReferenceNo, &t.Status, &t.PaidAt, &t.CreatedAt,
			&t.BillTitle,
		); err != nil {
			return nil, err
		}
		trxs = append(trxs, &t)
	}
	return trxs, nil
}

func (r *paymentRepository) UpdateBillStatus(ctx context.Context, billID uuid.UUID, paidAmount float64, status string) error {
	query := `UPDATE payment_bills SET paid_amount = ?, status = ? WHERE id = ?`
	_, err := r.db.ExecContext(ctx, query, paidAmount, status, billID)
	return err
}

func (r *paymentRepository) CreateTransaction(ctx context.Context, trx *domain.PaymentTransaction) error {
	query := `
		INSERT INTO payment_transactions (id, tenant_id, bill_id, student_id, amount, payment_method, reference_no, status, paid_at, created_at)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
	`
	_, err := r.db.ExecContext(ctx, query,
		trx.ID, trx.TenantID, trx.BillID, trx.StudentID, trx.Amount, trx.PaymentMethod, trx.ReferenceNo, trx.Status, trx.PaidAt, trx.CreatedAt,
	)
	return err
}

func (r *paymentRepository) GetBillByID(ctx context.Context, billID uuid.UUID) (*domain.PaymentBill, error) {
	query := `
		SELECT id, tenant_id, student_id, category_id, title, total_amount, paid_amount, status, due_date, created_at, updated_at
		FROM payment_bills
		WHERE id = ?
	`
	var b domain.PaymentBill
	if err := r.db.QueryRowContext(ctx, query, billID).Scan(
		&b.ID, &b.TenantID, &b.StudentID, &b.CategoryID, &b.Title, &b.TotalAmount, &b.PaidAmount, &b.Status, &b.DueDate, &b.CreatedAt, &b.UpdatedAt,
	); err != nil {
		return nil, err
	}
	return &b, nil
}
