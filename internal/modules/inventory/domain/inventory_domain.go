package domain

import (
	"context"
	"time"

	"github.com/google/uuid"
)

type InventoryItem struct {
	ID          uuid.UUID `json:"id"`
	TenantID    uuid.UUID `json:"tenant_id"`
	Name        string    `json:"name"`
	Description string    `json:"description"`
	Stock       int       `json:"stock"`
	Condition   string    `json:"condition"` // e.g. GOOD, NEEDS_REPAIR, BROKEN
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

type InventoryReport struct {
	ID          uuid.UUID `json:"id"`
	TenantID    uuid.UUID `json:"tenant_id"`
	ItemID      uuid.UUID `json:"item_id"`
	StaffID     uuid.UUID `json:"staff_id"`
	Condition   string    `json:"condition"`
	Notes       string    `json:"notes"`
	DocumentURL string    `json:"document_url"`
	CreatedAt   time.Time `json:"created_at"`
}

type InventoryRepository interface {
	ExecTx(ctx context.Context, fn func(repo InventoryRepository) error) error
	CreateItem(ctx context.Context, item *InventoryItem) error
	GetItemsByTenant(ctx context.Context, tenantID uuid.UUID) ([]*InventoryItem, error)
	GetItemByID(ctx context.Context, itemID uuid.UUID) (*InventoryItem, error)
	UpdateItemConditionAndStock(ctx context.Context, itemID uuid.UUID, condition string, stock int) error
	CreateReport(ctx context.Context, report *InventoryReport) error
}

type InventoryUsecase interface {
	GetItems(ctx context.Context, tenantID uuid.UUID) ([]*InventoryItem, error)
	CreateItem(ctx context.Context, item *InventoryItem) error
	ReportCondition(ctx context.Context, report *InventoryReport, stock int) error
}
