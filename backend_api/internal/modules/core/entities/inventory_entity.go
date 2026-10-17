package entities

import (
	"database/sql"
	"time"

	"github.com/google/uuid"
)

type InventoryCondition string

const (
	Good        InventoryCondition = "GOOD"
	Damaged     InventoryCondition = "DAMAGED"
	Maintenance InventoryCondition = "MAINTENANCE"
)

type Inventory struct {
	ID        uuid.UUID          `json:"id"`
	TenantID  uuid.UUID          `json:"tenant_id"`
	ItemCode  string             `json:"item_code"`
	Name      string             `json:"name"`
	Category  string             `json:"category"`
	Quantity  int                `json:"quantity"`
	Condition InventoryCondition `json:"condition"`
	Location  string             `json:"location"`
	ManagedBy uuid.UUID          `json:"managed_by"`
	CreatedAt time.Time          `json:"created_at"`
	UpdatedAt sql.NullTime       `json:"updated_at"`
	DeletedAt sql.NullTime       `json:"deleted_at"`
}
