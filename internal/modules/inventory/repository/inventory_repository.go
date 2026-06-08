package repository

import (
	"context"
	"database/sql"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/inventory/domain"
)

type inventoryRepository struct {
	db *sql.DB
}

func NewInventoryRepository(db *sql.DB) domain.InventoryRepository {
	return &inventoryRepository{db: db}
}

// ExecTx executes a function within a database transaction.
func (r *inventoryRepository) ExecTx(ctx context.Context, fn func(repo domain.InventoryRepository) error) error {
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}

	txRepo := &inventoryRepository{db: r.db}

	if err := fn(txRepo); err != nil {
		tx.Rollback()
		return err
	}

	return tx.Commit()
}

func (r *inventoryRepository) CreateItem(ctx context.Context, item *domain.InventoryItem) error {
	item.ID = uuid.New()
	query := `
		INSERT INTO inventory_items (id, tenant_id, name, description, stock, condition)
		VALUES (?, ?, ?, ?, ?, ?)
	`
	_, err := r.db.ExecContext(ctx, query, item.ID, item.TenantID, item.Name, item.Description, item.Stock, item.Condition)
	return err
}

func (r *inventoryRepository) GetItemsByTenant(ctx context.Context, tenantID uuid.UUID) ([]*domain.InventoryItem, error) {
	query := `
		SELECT id, tenant_id, name, description, stock, condition, created_at, updated_at
		FROM inventory_items
		WHERE tenant_id = ?
		ORDER BY created_at DESC
	`
	rows, err := r.db.QueryContext(ctx, query, tenantID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var items []*domain.InventoryItem
	for rows.Next() {
		var item domain.InventoryItem
		if err := rows.Scan(
			&item.ID, &item.TenantID, &item.Name, &item.Description,
			&item.Stock, &item.Condition, &item.CreatedAt, &item.UpdatedAt,
		); err != nil {
			return nil, err
		}
		items = append(items, &item)
	}
	return items, nil
}

func (r *inventoryRepository) GetItemByID(ctx context.Context, itemID uuid.UUID) (*domain.InventoryItem, error) {
	query := `
		SELECT id, tenant_id, name, description, stock, condition, created_at, updated_at
		FROM inventory_items
		WHERE id = ?
	`
	var item domain.InventoryItem
	err := r.db.QueryRowContext(ctx, query, itemID).Scan(
		&item.ID, &item.TenantID, &item.Name, &item.Description,
		&item.Stock, &item.Condition, &item.CreatedAt, &item.UpdatedAt,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	return &item, nil
}

func (r *inventoryRepository) UpdateItemConditionAndStock(ctx context.Context, itemID uuid.UUID, condition string, stock int) error {
	query := `
		UPDATE inventory_items
		SET condition = ?, stock = ?, updated_at = CURRENT_TIMESTAMP
		WHERE id = ?
	`
	_, err := r.db.ExecContext(ctx, query, condition, stock, itemID)
	return err
}

func (r *inventoryRepository) CreateReport(ctx context.Context, report *domain.InventoryReport) error {
	report.ID = uuid.New()
	query := `
		INSERT INTO inventory_reports (id, tenant_id, item_id, staff_id, condition, notes, document_url)
		VALUES (?, ?, ?, ?, ?, ?, ?)
	`
	_, err := r.db.ExecContext(ctx, query, report.ID, report.TenantID, report.ItemID, report.StaffID, report.Condition, report.Notes, report.DocumentURL)
	return err
}
