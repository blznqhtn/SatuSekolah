package domain

import (
	"context"
	"time"

	"github.com/google/uuid"
)

type CanteenOrderStatus string

const (
	OrderStatusPending    CanteenOrderStatus = "PENDING"
	OrderStatusPreparing  CanteenOrderStatus = "PREPARING"
	OrderStatusReady      CanteenOrderStatus = "READY"
	OrderStatusDelivering CanteenOrderStatus = "DELIVERING"
	OrderStatusCompleted  CanteenOrderStatus = "COMPLETED"
	OrderStatusCanceled   CanteenOrderStatus = "CANCELED"
)

type CanteenShop struct {
	ID           uuid.UUID  `json:"id"`
	TenantID     uuid.UUID  `json:"tenant_id"`
	OwnerID      uuid.UUID  `json:"owner_id"`
	Name            string     `json:"name"`
	StaticQRCode    string     `json:"static_qr_code"`
	AllowDelivery   bool       `json:"allow_delivery"`
	BaseDeliveryFee float64    `json:"base_delivery_fee"`
	CreatedAt    time.Time  `json:"created_at"`
	UpdatedAt    time.Time  `json:"updated_at"`
	DeletedAt    *time.Time `json:"deleted_at,omitempty"`
}

type CanteenItem struct {
	ID          uuid.UUID  `json:"id"`
	ShopID      uuid.UUID  `json:"shop_id"`
	Name        string     `json:"name"`
	Description string     `json:"description"`
	Price       float64    `json:"price"`
	Stock       int        `json:"stock"`
	ImageURL    string     `json:"image_url"`
	CreatedAt   time.Time  `json:"created_at"`
	UpdatedAt   time.Time  `json:"updated_at"`
	DeletedAt   *time.Time               `json:"deleted_at,omitempty"`
	Ingredients []CanteenItemIngredient `json:"ingredients,omitempty"`
}

type CanteenItemIngredient struct {
	ID        uuid.UUID `json:"id"`
	ItemID    uuid.UUID `json:"item_id"`
	Name      string    `json:"name"`
	Cost      float64   `json:"cost"`
	Quantity  float64   `json:"quantity"`
	Unit      string    `json:"unit"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

type CanteenDiscount struct {
	ID           uuid.UUID  `json:"id"`
	ShopID       uuid.UUID  `json:"shop_id"`
	ItemID       *uuid.UUID `json:"item_id,omitempty"` // If null, applies to all items in shop
	DiscountType string     `json:"discount_type"` // PERCENTAGE or FIXED_AMOUNT
	Value        float64    `json:"value"`
	StartDate    *time.Time `json:"start_date,omitempty"`
	EndDate      *time.Time `json:"end_date,omitempty"`
	MaxUses      *int       `json:"max_uses,omitempty"`
	CurrentUses  int        `json:"current_uses"`
	CreatedAt    time.Time  `json:"created_at"`
}

type CanteenCart struct {
	ID        uuid.UUID `json:"id"`
	UserID    uuid.UUID `json:"user_id"`
	ItemID    uuid.UUID `json:"item_id"`
	Quantity  int       `json:"quantity"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

type CanteenOrder struct {
	ID             uuid.UUID          `json:"id"`
	ShopID         uuid.UUID          `json:"shop_id"`
	BuyerID        *uuid.UUID         `json:"buyer_id,omitempty"`
	WalletLedgerID *uuid.UUID         `json:"wallet_ledger_id,omitempty"`
	TotalAmount    float64            `json:"total_amount"`
	DeliveryFee    float64            `json:"delivery_fee"`
	DeliveryMethod string             `json:"delivery_method"` // PICKUP or DELIVERY
	IsPreorder     bool               `json:"is_preorder"`
	PreorderDate   *string            `json:"preorder_date,omitempty"` // YYYY-MM-DD
	PreorderTime   *string            `json:"preorder_time,omitempty"` // HH:MM
	Status               CanteenOrderStatus `json:"status"`
	PaymentMethod        string             `json:"payment_method"`
	DynamicQRCode        *string            `json:"dynamic_qr_code,omitempty"`
	RFIDPaymentCode      *string            `json:"rfid_payment_code,omitempty"`
	TransferTargetAccount *string           `json:"transfer_target_account,omitempty"`
	ExpiresAt            *time.Time         `json:"expires_at,omitempty"`
	CreatedAt            time.Time          `json:"created_at"`
	UpdatedAt            time.Time          `json:"updated_at"`
	Items                []CanteenOrderItem `json:"items,omitempty"`
}

type CanteenOrderItem struct {
	ID              uuid.UUID `json:"id"`
	OrderID         uuid.UUID `json:"order_id"`
	ItemID          uuid.UUID `json:"item_id"`
	Quantity        int       `json:"quantity"`
	PriceAtPurchase float64   `json:"price_at_purchase"`
}

type FinancialReport struct {
	Date        string  `json:"date"`
	TotalOrders int     `json:"total_orders"`
	GrossProfit float64 `json:"gross_profit"`
	TotalCost   float64 `json:"total_cost"`
	NetProfit   float64 `json:"net_profit"`
}

type CanteenAIInsight struct {
	ShopID      uuid.UUID `json:"shop_id"`
	Month       string    `json:"month"`
	InsightText string    `json:"insight_text"`
	GeneratedAt time.Time `json:"generated_at"`
}

type CanteenRepository interface {
	ExecTx(ctx context.Context, fn func(repo CanteenRepository) error) error

	CreateShop(ctx context.Context, shop *CanteenShop) error
	GetShopByOwnerID(ctx context.Context, ownerID uuid.UUID) (*CanteenShop, error)
	GetShopByQRCode(ctx context.Context, qrCode string) (*CanteenShop, error)
	GetShopByID(ctx context.Context, shopID uuid.UUID) (*CanteenShop, error)

	CreateItem(ctx context.Context, item *CanteenItem) error
	CreateItemIngredient(ctx context.Context, ingredient *CanteenItemIngredient) error
	GetIngredientsByItemID(ctx context.Context, itemID uuid.UUID) ([]*CanteenItemIngredient, error)
	GetItemsByShopID(ctx context.Context, shopID uuid.UUID) ([]*CanteenItem, error)
	GetItemByID(ctx context.Context, itemID uuid.UUID) (*CanteenItem, error)

	CreateDiscount(ctx context.Context, discount *CanteenDiscount) error
	GetActiveDiscounts(ctx context.Context, shopID uuid.UUID) ([]*CanteenDiscount, error)
	IncrementDiscountUses(ctx context.Context, discountID uuid.UUID) error

	AddToCart(ctx context.Context, cart *CanteenCart) error
	GetCartItems(ctx context.Context, userID uuid.UUID) ([]*CanteenCart, error)
	ClearCart(ctx context.Context, userID uuid.UUID) error

	CreateOrder(ctx context.Context, order *CanteenOrder) error
	CreateOrderItem(ctx context.Context, orderItem *CanteenOrderItem) error
	UpdateOrderStatus(ctx context.Context, orderID uuid.UUID, status CanteenOrderStatus) error
	GetOrder(ctx context.Context, orderID uuid.UUID) (*CanteenOrder, error)
	GetOrdersByShop(ctx context.Context, shopID uuid.UUID) ([]*CanteenOrder, error)
	GetOrderByDynamicQR(ctx context.Context, qrCode string) (*CanteenOrder, error)
	GetOrderByRFIDPaymentCode(ctx context.Context, rfidPaymentCode string) (*CanteenOrder, error)
	GetOrderByTransferAccount(ctx context.Context, transferAccount string) (*CanteenOrder, error)

	GetDailyFinancialReport(ctx context.Context, shopID uuid.UUID, startDate, endDate string) ([]FinancialReport, error)
}

type CanteenUsecase interface {
	CreateShop(ctx context.Context, tenantID, ownerID uuid.UUID, name string) (*CanteenShop, error)
	AddItem(ctx context.Context, ownerID uuid.UUID, req *CanteenItem) error
	
	AddToCart(ctx context.Context, userID, itemID uuid.UUID, quantity int) error
	CheckoutCart(ctx context.Context, tenantID, userID uuid.UUID, isPreorder bool, preorderDate, preorderTime string, deliveryMethod string, pin string) (*CanteenOrder, error)
	
	// POS Flow
	CreatePOSOrder(ctx context.Context, ownerID uuid.UUID, items []CanteenOrderItem, paymentMethod string) (*CanteenOrder, error)
	PayViaDynamicQR(ctx context.Context, buyerID uuid.UUID, dynamicQRCode string, pin string) (*CanteenOrder, error)
	GetOrderForIoT(ctx context.Context, rfidPaymentCode string) (*CanteenOrder, error)
	PayViaRFID(ctx context.Context, rfidPaymentCode string, rfidTag string, pin string) (*CanteenOrder, error)

	AddDiscount(ctx context.Context, ownerID uuid.UUID, req *CanteenDiscount) error
	UpdateOrderStatus(ctx context.Context, ownerID, orderID uuid.UUID, status string) error
	GetFinancialReport(ctx context.Context, ownerID uuid.UUID, startDate, endDate string) ([]FinancialReport, error)
	GenerateAIInsight(ctx context.Context, ownerID uuid.UUID, month string) (*CanteenAIInsight, error)
}
