package repository

import (
	"context"
	"database/sql"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/canteen/domain"
)

type canteenRepository struct {
	db *sql.DB
	tx *sql.Tx
}

func NewCanteenRepository(db *sql.DB) domain.CanteenRepository {
	return &canteenRepository{db: db}
}

func (r *canteenRepository) ExecTx(ctx context.Context, fn func(repo domain.CanteenRepository) error) error {
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}

	txRepo := &canteenRepository{
		db: r.db,
		tx: tx,
	}

	if err := fn(txRepo); err != nil {
		if rbErr := tx.Rollback(); rbErr != nil {
			return rbErr
		}
		return err
	}

	return tx.Commit()
}

func (r *canteenRepository) queryRow(ctx context.Context, query string, args ...interface{}) *sql.Row {
	if r.tx != nil {
		return r.tx.QueryRowContext(ctx, query, args...)
	}
	return r.db.QueryRowContext(ctx, query, args...)
}

func (r *canteenRepository) exec(ctx context.Context, query string, args ...interface{}) (sql.Result, error) {
	if r.tx != nil {
		return r.tx.ExecContext(ctx, query, args...)
	}
	return r.db.ExecContext(ctx, query, args...)
}

func (r *canteenRepository) CreateShop(ctx context.Context, shop *domain.CanteenShop) error {
	query := `INSERT INTO canteen_shops (id, tenant_id, owner_id, name, static_qr_code, allow_delivery, base_delivery_fee) VALUES ($1, $2, $3, $4, $5, $6, $7)`
	shop.ID = uuid.New()
	_, err := r.exec(ctx, query, shop.ID, shop.TenantID, shop.OwnerID, shop.Name, shop.StaticQRCode, shop.AllowDelivery, shop.BaseDeliveryFee)
	return err
}

func (r *canteenRepository) GetShopByOwnerID(ctx context.Context, ownerID uuid.UUID) (*domain.CanteenShop, error) {
	query := `SELECT id, tenant_id, owner_id, name, static_qr_code, allow_delivery, base_delivery_fee, created_at, updated_at FROM canteen_shops WHERE owner_id = $1 AND deleted_at IS NULL LIMIT 1`
	var s domain.CanteenShop
	err := r.queryRow(ctx, query, ownerID).Scan(&s.ID, &s.TenantID, &s.OwnerID, &s.Name, &s.StaticQRCode, &s.AllowDelivery, &s.BaseDeliveryFee, &s.CreatedAt, &s.UpdatedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return &s, err
}

func (r *canteenRepository) GetShopByQRCode(ctx context.Context, qrCode string) (*domain.CanteenShop, error) {
	query := `SELECT id, tenant_id, owner_id, name, static_qr_code, allow_delivery, base_delivery_fee, created_at, updated_at FROM canteen_shops WHERE static_qr_code = $1 AND deleted_at IS NULL LIMIT 1`
	var s domain.CanteenShop
	err := r.queryRow(ctx, query, qrCode).Scan(&s.ID, &s.TenantID, &s.OwnerID, &s.Name, &s.StaticQRCode, &s.AllowDelivery, &s.BaseDeliveryFee, &s.CreatedAt, &s.UpdatedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return &s, err
}

func (r *canteenRepository) GetShopByID(ctx context.Context, shopID uuid.UUID) (*domain.CanteenShop, error) {
	query := `SELECT id, tenant_id, owner_id, name, static_qr_code, allow_delivery, base_delivery_fee, created_at, updated_at FROM canteen_shops WHERE id = $1 AND deleted_at IS NULL LIMIT 1`
	var s domain.CanteenShop
	err := r.queryRow(ctx, query, shopID).Scan(&s.ID, &s.TenantID, &s.OwnerID, &s.Name, &s.StaticQRCode, &s.AllowDelivery, &s.BaseDeliveryFee, &s.CreatedAt, &s.UpdatedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return &s, err
}

func (r *canteenRepository) CreateItem(ctx context.Context, item *domain.CanteenItem) error {
	query := `INSERT INTO canteen_items (id, shop_id, name, description, price, stock, image_url) VALUES ($1, $2, $3, $4, $5, $6, $7)`
	item.ID = uuid.New()
	_, err := r.exec(ctx, query, item.ID, item.ShopID, item.Name, item.Description, item.Price, item.Stock, item.ImageURL)
	return err
}

func (r *canteenRepository) CreateItemIngredient(ctx context.Context, ingredient *domain.CanteenItemIngredient) error {
	query := `INSERT INTO canteen_item_ingredients (id, item_id, name, cost, quantity, unit) VALUES ($1, $2, $3, $4, $5, $6)`
	ingredient.ID = uuid.New()
	_, err := r.exec(ctx, query, ingredient.ID, ingredient.ItemID, ingredient.Name, ingredient.Cost, ingredient.Quantity, ingredient.Unit)
	return err
}

func (r *canteenRepository) GetIngredientsByItemID(ctx context.Context, itemID uuid.UUID) ([]*domain.CanteenItemIngredient, error) {
	query := `SELECT id, item_id, name, cost, quantity, unit, created_at, updated_at FROM canteen_item_ingredients WHERE item_id = $1`
	rows, err := r.db.QueryContext(ctx, query, itemID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var ingredients []*domain.CanteenItemIngredient
	for rows.Next() {
		var i domain.CanteenItemIngredient
		if err := rows.Scan(&i.ID, &i.ItemID, &i.Name, &i.Cost, &i.Quantity, &i.Unit, &i.CreatedAt, &i.UpdatedAt); err != nil {
			return nil, err
		}
		ingredients = append(ingredients, &i)
	}
	return ingredients, nil
}

func (r *canteenRepository) GetItemsByShopID(ctx context.Context, shopID uuid.UUID) ([]*domain.CanteenItem, error) {
	query := `SELECT id, shop_id, name, description, price, stock, image_url FROM canteen_items WHERE shop_id = $1 AND deleted_at IS NULL`
	rows, err := r.db.QueryContext(ctx, query, shopID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var items []*domain.CanteenItem
	for rows.Next() {
		var i domain.CanteenItem
		if err := rows.Scan(&i.ID, &i.ShopID, &i.Name, &i.Description, &i.Price, &i.Stock, &i.ImageURL); err != nil {
			return nil, err
		}
		items = append(items, &i)
	}
	return items, nil
}

func (r *canteenRepository) GetItemByID(ctx context.Context, itemID uuid.UUID) (*domain.CanteenItem, error) {
	query := `SELECT id, shop_id, name, description, price, stock, image_url FROM canteen_items WHERE id = $1 AND deleted_at IS NULL`
	var i domain.CanteenItem
	err := r.queryRow(ctx, query, itemID).Scan(&i.ID, &i.ShopID, &i.Name, &i.Description, &i.Price, &i.Stock, &i.ImageURL)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return &i, err
}

func (r *canteenRepository) CreateDiscount(ctx context.Context, discount *domain.CanteenDiscount) error {
	query := `INSERT INTO canteen_discounts (id, shop_id, item_id, discount_type, value, start_date, end_date, max_uses, current_uses) 
			  VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`
	discount.ID = uuid.New()
	_, err := r.exec(ctx, query, discount.ID, discount.ShopID, discount.ItemID, discount.DiscountType, discount.Value, discount.StartDate, discount.EndDate, discount.MaxUses, discount.CurrentUses)
	return err
}

func (r *canteenRepository) GetActiveDiscounts(ctx context.Context, shopID uuid.UUID) ([]*domain.CanteenDiscount, error) {
	query := `SELECT id, shop_id, item_id, discount_type, value, start_date, end_date, max_uses, current_uses, created_at 
			  FROM canteen_discounts 
			  WHERE shop_id = $1 
			  AND (start_date IS NULL OR start_date <= CURRENT_TIMESTAMP) 
			  AND (end_date IS NULL OR end_date >= CURRENT_TIMESTAMP)
			  AND (max_uses IS NULL OR current_uses < max_uses)`
	
	rows, err := r.db.QueryContext(ctx, query, shopID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var discounts []*domain.CanteenDiscount
	for rows.Next() {
		var d domain.CanteenDiscount
		if err := rows.Scan(&d.ID, &d.ShopID, &d.ItemID, &d.DiscountType, &d.Value, &d.StartDate, &d.EndDate, &d.MaxUses, &d.CurrentUses, &d.CreatedAt); err != nil {
			return nil, err
		}
		discounts = append(discounts, &d)
	}
	return discounts, nil
}

func (r *canteenRepository) IncrementDiscountUses(ctx context.Context, discountID uuid.UUID) error {
	query := `UPDATE canteen_discounts SET current_uses = current_uses + 1 WHERE id = $1`
	_, err := r.exec(ctx, query, discountID)
	return err
}

func (r *canteenRepository) AddToCart(ctx context.Context, cart *domain.CanteenCart) error {
	query := `
		INSERT INTO canteen_carts (id, user_id, item_id, quantity) 
		VALUES ($1, $2, $3, $4)
		ON CONFLICT (id) DO UPDATE SET quantity = canteen_carts.quantity + EXCLUDED.quantity
	`
	cart.ID = uuid.New()
	_, err := r.exec(ctx, query, cart.ID, cart.UserID, cart.ItemID, cart.Quantity)
	return err
}

func (r *canteenRepository) GetCartItems(ctx context.Context, userID uuid.UUID) ([]*domain.CanteenCart, error) {
	query := `SELECT id, user_id, item_id, quantity FROM canteen_carts WHERE user_id = $1`
	rows, err := r.db.QueryContext(ctx, query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var carts []*domain.CanteenCart
	for rows.Next() {
		var c domain.CanteenCart
		if err := rows.Scan(&c.ID, &c.UserID, &c.ItemID, &c.Quantity); err != nil {
			return nil, err
		}
		carts = append(carts, &c)
	}
	return carts, nil
}

func (r *canteenRepository) ClearCart(ctx context.Context, userID uuid.UUID) error {
	query := `DELETE FROM canteen_carts WHERE user_id = $1`
	_, err := r.exec(ctx, query, userID)
	return err
}

func (r *canteenRepository) CreateOrder(ctx context.Context, order *domain.CanteenOrder) error {
	query := `
		INSERT INTO canteen_orders (id, shop_id, buyer_id, wallet_ledger_id, total_amount, delivery_fee, delivery_method, is_preorder, preorder_date, preorder_time, payment_method, dynamic_qr_code, rfid_payment_code, transfer_target_account, expires_at, status)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16)
	`
	order.ID = uuid.New()
	_, err := r.exec(ctx, query, order.ID, order.ShopID, order.BuyerID, order.WalletLedgerID, order.TotalAmount, order.DeliveryFee, order.DeliveryMethod, order.IsPreorder, order.PreorderDate, order.PreorderTime, order.PaymentMethod, order.DynamicQRCode, order.RFIDPaymentCode, order.TransferTargetAccount, order.ExpiresAt, order.Status)
	return err
}

func (r *canteenRepository) CreateOrderItem(ctx context.Context, orderItem *domain.CanteenOrderItem) error {
	query := `
		INSERT INTO canteen_order_items (id, order_id, item_id, quantity, price_at_purchase)
		VALUES ($1, $2, $3, $4, $5)
	`
	orderItem.ID = uuid.New()
	_, err := r.exec(ctx, query, orderItem.ID, orderItem.OrderID, orderItem.ItemID, orderItem.Quantity, orderItem.PriceAtPurchase)
	return err
}

func (r *canteenRepository) UpdateOrderStatus(ctx context.Context, orderID uuid.UUID, status domain.CanteenOrderStatus) error {
	query := `UPDATE canteen_orders SET status = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2`
	_, err := r.exec(ctx, query, status, orderID)
	return err
}

func (r *canteenRepository) UpdatePaymentMethod(ctx context.Context, orderID uuid.UUID, paymentMethod string) error {
	query := `UPDATE canteen_orders SET payment_method = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2`
	_, err := r.exec(ctx, query, paymentMethod, orderID)
	return err
}

func (r *canteenRepository) GetOrder(ctx context.Context, orderID uuid.UUID) (*domain.CanteenOrder, error) {
	query := `SELECT id, shop_id, buyer_id, wallet_ledger_id, total_amount, delivery_fee, delivery_method, is_preorder, preorder_date, preorder_time, payment_method, dynamic_qr_code, rfid_payment_code, transfer_target_account, expires_at, status, created_at, updated_at FROM canteen_orders WHERE id = $1`
	var o domain.CanteenOrder
	err := r.queryRow(ctx, query, orderID).Scan(&o.ID, &o.ShopID, &o.BuyerID, &o.WalletLedgerID, &o.TotalAmount, &o.DeliveryFee, &o.DeliveryMethod, &o.IsPreorder, &o.PreorderDate, &o.PreorderTime, &o.PaymentMethod, &o.DynamicQRCode, &o.RFIDPaymentCode, &o.TransferTargetAccount, &o.ExpiresAt, &o.Status, &o.CreatedAt, &o.UpdatedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return &o, err
}

func (r *canteenRepository) GetOrdersByShop(ctx context.Context, shopID uuid.UUID) ([]*domain.CanteenOrder, error) {
	query := `SELECT id, shop_id, buyer_id, wallet_ledger_id, total_amount, delivery_fee, delivery_method, is_preorder, preorder_date, preorder_time, payment_method, dynamic_qr_code, rfid_payment_code, transfer_target_account, expires_at, status, created_at, updated_at FROM canteen_orders WHERE shop_id = $1 ORDER BY created_at DESC`
	rows, err := r.db.QueryContext(ctx, query, shopID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var orders []*domain.CanteenOrder
	for rows.Next() {
		var o domain.CanteenOrder
		if err := rows.Scan(&o.ID, &o.ShopID, &o.BuyerID, &o.WalletLedgerID, &o.TotalAmount, &o.DeliveryFee, &o.DeliveryMethod, &o.IsPreorder, &o.PreorderDate, &o.PreorderTime, &o.PaymentMethod, &o.DynamicQRCode, &o.RFIDPaymentCode, &o.TransferTargetAccount, &o.ExpiresAt, &o.Status, &o.CreatedAt, &o.UpdatedAt); err != nil {
			return nil, err
		}
		orders = append(orders, &o)
	}
	return orders, nil
}

func (r *canteenRepository) GetOrderByDynamicQR(ctx context.Context, qrCode string) (*domain.CanteenOrder, error) {
	query := `SELECT id, shop_id, buyer_id, wallet_ledger_id, total_amount, delivery_fee, delivery_method, is_preorder, preorder_date, preorder_time, payment_method, dynamic_qr_code, rfid_payment_code, transfer_target_account, expires_at, status, created_at, updated_at FROM canteen_orders WHERE dynamic_qr_code = $1 LIMIT 1`
	var o domain.CanteenOrder
	err := r.queryRow(ctx, query, qrCode).Scan(&o.ID, &o.ShopID, &o.BuyerID, &o.WalletLedgerID, &o.TotalAmount, &o.DeliveryFee, &o.DeliveryMethod, &o.IsPreorder, &o.PreorderDate, &o.PreorderTime, &o.PaymentMethod, &o.DynamicQRCode, &o.RFIDPaymentCode, &o.TransferTargetAccount, &o.ExpiresAt, &o.Status, &o.CreatedAt, &o.UpdatedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return &o, err
}

func (r *canteenRepository) GetOrderByRFIDPaymentCode(ctx context.Context, rfidPaymentCode string) (*domain.CanteenOrder, error) {
	query := `SELECT id, shop_id, buyer_id, wallet_ledger_id, total_amount, delivery_fee, delivery_method, is_preorder, preorder_date, preorder_time, payment_method, dynamic_qr_code, rfid_payment_code, transfer_target_account, expires_at, status, created_at, updated_at FROM canteen_orders WHERE rfid_payment_code = $1 LIMIT 1`
	var o domain.CanteenOrder
	err := r.queryRow(ctx, query, rfidPaymentCode).Scan(&o.ID, &o.ShopID, &o.BuyerID, &o.WalletLedgerID, &o.TotalAmount, &o.DeliveryFee, &o.DeliveryMethod, &o.IsPreorder, &o.PreorderDate, &o.PreorderTime, &o.PaymentMethod, &o.DynamicQRCode, &o.RFIDPaymentCode, &o.TransferTargetAccount, &o.ExpiresAt, &o.Status, &o.CreatedAt, &o.UpdatedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return &o, err
}

func (r *canteenRepository) GetOrderByTransferAccount(ctx context.Context, transferAccount string) (*domain.CanteenOrder, error) {
	query := `SELECT id, shop_id, buyer_id, wallet_ledger_id, total_amount, delivery_fee, delivery_method, is_preorder, preorder_date, preorder_time, payment_method, dynamic_qr_code, rfid_payment_code, transfer_target_account, expires_at, status, created_at, updated_at FROM canteen_orders WHERE transfer_target_account = $1 LIMIT 1`
	var o domain.CanteenOrder
	err := r.queryRow(ctx, query, transferAccount).Scan(&o.ID, &o.ShopID, &o.BuyerID, &o.WalletLedgerID, &o.TotalAmount, &o.DeliveryFee, &o.DeliveryMethod, &o.IsPreorder, &o.PreorderDate, &o.PreorderTime, &o.PaymentMethod, &o.DynamicQRCode, &o.RFIDPaymentCode, &o.TransferTargetAccount, &o.ExpiresAt, &o.Status, &o.CreatedAt, &o.UpdatedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return &o, err
}

func (r *canteenRepository) GetDailyFinancialReport(ctx context.Context, shopID uuid.UUID, startDate, endDate string) ([]domain.FinancialReport, error) {
	// For Net profit, we need to sum up ingredients cost for the items ordered.
	// We'll calculate Total Cost as SUM(order_item.quantity * ingredient.cost)
	query := `
		SELECT 
			DATE(o.created_at) as date, 
			COUNT(DISTINCT o.id) as total_orders, 
			SUM(o.total_amount) as gross_profit,
			COALESCE((
				SELECT SUM(oi.quantity * ii.cost)
				FROM canteen_order_items oi
				JOIN canteen_item_ingredients ii ON oi.item_id = ii.item_id
				WHERE oi.order_id = o.id
			), 0) as total_cost
		FROM canteen_orders o
		WHERE o.shop_id = $1 AND o.status = 'COMPLETED' AND o.created_at >= $2 AND o.created_at <= $3
		GROUP BY DATE(o.created_at), o.id
	`
	// The above query calculates per order, we need to wrap it to aggregate per date.
	wrappedQuery := `
		SELECT 
			t.date,
			COUNT(t.id) as total_orders,
			SUM(t.gross_profit) as gross_profit,
			SUM(t.total_cost) as total_cost
		FROM (
			SELECT 
				o.id,
				DATE(o.created_at) as date, 
				o.total_amount as gross_profit,
				COALESCE((
					SELECT SUM(oi.quantity * ii.cost * ii.quantity)
					FROM canteen_order_items oi
					JOIN canteen_item_ingredients ii ON oi.item_id = ii.item_id
					WHERE oi.order_id = o.id
				), 0) as total_cost
			FROM canteen_orders o
			WHERE o.shop_id = $1 AND o.status = 'COMPLETED' AND o.created_at >= $2 AND o.created_at <= $3
		) t
		GROUP BY t.date
		ORDER BY t.date ASC
	`

	rows, err := r.db.QueryContext(ctx, query, shopID, startDate, endDate)
	if err != nil {
		// fallback if sqlite syntax differs
		rows, err = r.db.QueryContext(ctx, wrappedQuery, shopID, startDate, endDate)
		if err != nil {
			return nil, err
		}
	} else {
		rows.Close()
		rows, err = r.db.QueryContext(ctx, wrappedQuery, shopID, startDate, endDate)
		if err != nil {
			return nil, err
		}
	}
	defer rows.Close()

	var reports []domain.FinancialReport
	for rows.Next() {
		var rep domain.FinancialReport
		if err := rows.Scan(&rep.Date, &rep.TotalOrders, &rep.GrossProfit, &rep.TotalCost); err != nil {
			return nil, err
		}
		rep.NetProfit = rep.GrossProfit - rep.TotalCost
		reports = append(reports, rep)
	}
	return reports, nil
}
