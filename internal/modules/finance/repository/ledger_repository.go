package repository

import (
	"context"
	"database/sql"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/finance/domain"
)

type ledgerRepository struct {
	db *sql.DB
	tx *sql.Tx
}

// NewLedgerRepository creates a new instance of LedgerRepository
func NewLedgerRepository(db *sql.DB) domain.LedgerRepository {
	return &ledgerRepository{
		db: db,
	}
}

func (r *ledgerRepository) ExecTx(ctx context.Context, fn func(repo domain.LedgerRepository) error) error {
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}

	txRepo := &ledgerRepository{
		db: r.db,
		tx: tx,
	}

	if err := fn(txRepo); err != nil {
		_ = tx.Rollback()
		return err
	}
	return tx.Commit()
}

func (r *ledgerRepository) queryRow(ctx context.Context, query string, args ...interface{}) *sql.Row {
	if r.tx != nil {
		return r.tx.QueryRowContext(ctx, query, args...)
	}
	return r.db.QueryRowContext(ctx, query, args...)
}

func (r *ledgerRepository) exec(ctx context.Context, query string, args ...interface{}) (sql.Result, error) {
	if r.tx != nil {
		return r.tx.ExecContext(ctx, query, args...)
	}
	return r.db.ExecContext(ctx, query, args...)
}

func (r *ledgerRepository) GetLatestLedger(ctx context.Context, tenantID, userID uuid.UUID) (*domain.WalletLedger, error) {
	query := `
		SELECT id, tenant_id, user_id, transaction_type, amount, fee, reference_type, reference_id, previous_hash, current_hash, created_at
		FROM wallet_ledgers 
		WHERE tenant_id = $1 AND user_id = $2
		ORDER BY created_at DESC 
		LIMIT 1
	`
	row := r.queryRow(ctx, query, tenantID, userID)

	var ledger domain.WalletLedger
	err := row.Scan(
		&ledger.ID, &ledger.TenantID, &ledger.UserID, &ledger.TransactionType,
		&ledger.Amount, &ledger.Fee, &ledger.ReferenceType, &ledger.ReferenceID,
		&ledger.PreviousHash, &ledger.CurrentHash, &ledger.CreatedAt,
	)

	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil // First transaction
		}
		return nil, err
	}

	return &ledger, nil
}

func (r *ledgerRepository) AppendLedger(ctx context.Context, ledger *domain.WalletLedger) error {
	query := `
		INSERT INTO wallet_ledgers (
			tenant_id, user_id, transaction_type, amount, fee, reference_type, reference_id, previous_hash, current_hash
		) VALUES (
			$1, $2, $3, $4, $5, $6, $7, $8, $9
		) RETURNING id, created_at
	`
	err := r.queryRow(ctx, query,
		ledger.TenantID, ledger.UserID, ledger.TransactionType, ledger.Amount,
		ledger.Fee, ledger.ReferenceType, ledger.ReferenceID, ledger.PreviousHash, ledger.CurrentHash,
	).Scan(&ledger.ID, &ledger.CreatedAt)

	return err
}

func (r *ledgerRepository) UpdateCachedBalance(ctx context.Context, userID uuid.UUID, newBalance float64) error {
	query := `UPDATE users SET wallet_balance = $1 WHERE id = $2`
	_, err := r.exec(ctx, query, newBalance, userID)
	return err
}

func (r *ledgerRepository) GetAggregatedBalance(ctx context.Context, userID uuid.UUID) (float64, error) {
	query := `
		SELECT 
			COALESCE(SUM(CASE WHEN transaction_type = 'CREDIT' THEN amount ELSE 0 END), 0) -
			COALESCE(SUM(CASE WHEN transaction_type = 'DEBIT' THEN amount ELSE 0 END), 0) AS actual_balance
		FROM wallet_ledgers
		WHERE user_id = $1
	`
	var balance float64
	err := r.queryRow(ctx, query, userID).Scan(&balance)
	return balance, err
}

func (r *ledgerRepository) GetTransactionHistory(ctx context.Context, tenantID, userID uuid.UUID) ([]*domain.WalletLedger, error) {
	query := `
		SELECT id, tenant_id, user_id, transaction_type, amount, fee, reference_type, reference_id, previous_hash, current_hash, created_at
		FROM wallet_ledgers
		WHERE tenant_id = $1 AND user_id = $2
		ORDER BY created_at DESC
	`
	rows, err := r.db.QueryContext(ctx, query, tenantID, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var ledgers []*domain.WalletLedger
	for rows.Next() {
		var l domain.WalletLedger
		if err := rows.Scan(
			&l.ID, &l.TenantID, &l.UserID, &l.TransactionType,
			&l.Amount, &l.Fee, &l.ReferenceType, &l.ReferenceID,
			&l.PreviousHash, &l.CurrentHash, &l.CreatedAt,
		); err != nil {
			return nil, err
		}
		ledgers = append(ledgers, &l)
	}
	return ledgers, nil
}

