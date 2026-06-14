package repository

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"math/rand"
	"strconv"
	"time"

	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/core/domain"
	"neuracakrawira.asia/satu-sekolah-backend/pkg/cache"
)

// generateBankCode generates a random 3-digit numeric bank code
func generateBankCode() string {
	return fmt.Sprintf("%03d", rand.Intn(900)+100) // 100-999
}

// generateAccountNumber creates a 12-digit account number:
// First 3 digits = tenant bank_code, last 9 digits = random
func generateAccountNumber(bankCode string) string {
	return fmt.Sprintf("%s%09d", bankCode, rand.Intn(1000000000))
}

type coreRepository struct {
	db    *sql.DB
	tx    *sql.Tx
	cache cache.Cache
}

// NewCoreRepository creates a new instance of CoreRepository
func NewCoreRepository(db *sql.DB, c cache.Cache) domain.CoreRepository {
	return &coreRepository{
		db:    db,
		cache: c,
	}
}

// ExecTx executes a function within a database transaction
func (r *coreRepository) ExecTx(ctx context.Context, fn func(repo domain.CoreRepository) error) error {
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}

	// Create a new instance of repository that uses this transaction
	txRepo := &coreRepository{
		db:    r.db,
		tx:    tx,
		cache: r.cache,
	}

	err = fn(txRepo)
	if err != nil {
		if rbErr := tx.Rollback(); rbErr != nil {
			return rbErr
		}
		return err
	}

	return tx.Commit()
}

// queryRow is a helper to use tx if available, otherwise db
func (r *coreRepository) queryRow(ctx context.Context, query string, args ...interface{}) *sql.Row {
	if r.tx != nil {
		return r.tx.QueryRowContext(ctx, query, args...)
	}
	return r.db.QueryRowContext(ctx, query, args...)
}

// exec is a helper to use tx if available, otherwise db
func (r *coreRepository) exec(ctx context.Context, query string, args ...interface{}) (sql.Result, error) {
	if r.tx != nil {
		return r.tx.ExecContext(ctx, query, args...)
	}
	return r.db.ExecContext(ctx, query, args...)
}

func (r *coreRepository) CreateTenant(ctx context.Context, tenant *domain.Tenant) error {
	// Auto-generate a unique 3-digit bank code for this school
	tenant.BankCode = generateBankCode()

	query := `
		INSERT INTO tenants (name, bank_code, npsn, domain, address, phone, email, logo_url)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?)
	`
	result, err := r.exec(ctx, query,
		tenant.Name, tenant.BankCode, tenant.NPSN, tenant.Domain, tenant.Address, tenant.Phone, tenant.Email, tenant.LogoURL,
	)
	if err != nil {
		return err
	}
	// MySQL uses LastInsertId for auto-increment; for UUID we set it before insert
	// Since our PK is a UUID string we generate it here
	tenant.ID = uuid.New()
	_ = result
	return nil
}

func (r *coreRepository) GetTenantByID(ctx context.Context, id uuid.UUID) (*domain.Tenant, error) {
	query := `
		SELECT id, name, bank_code, npsn, domain, address, phone, email, logo_url, created_at, updated_at, deleted_at
		FROM tenants WHERE id = ? AND deleted_at IS NULL
	`
	row := r.queryRow(ctx, query, id)

	var tenant domain.Tenant
	err := row.Scan(
		&tenant.ID, &tenant.Name, &tenant.BankCode, &tenant.NPSN, &tenant.Domain, &tenant.Address,
		&tenant.Phone, &tenant.Email, &tenant.LogoURL, &tenant.CreatedAt,
		&tenant.UpdatedAt, &tenant.DeletedAt,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}

	return &tenant, nil
}

func (r *coreRepository) GetTenantByDomain(ctx context.Context, domainStr string) (*domain.Tenant, error) {
	query := `
		SELECT id, name, bank_code, npsn, domain, address, phone, email, logo_url, created_at, updated_at, deleted_at
		FROM tenants WHERE domain = ? AND deleted_at IS NULL
	`
	row := r.queryRow(ctx, query, domainStr)

	var tenant domain.Tenant
	err := row.Scan(
		&tenant.ID, &tenant.Name, &tenant.BankCode, &tenant.NPSN, &tenant.Domain, &tenant.Address,
		&tenant.Phone, &tenant.Email, &tenant.LogoURL, &tenant.CreatedAt,
		&tenant.UpdatedAt, &tenant.DeletedAt,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}

	return &tenant, nil
}

func (r *coreRepository) GetFirstTenant(ctx context.Context) (*domain.Tenant, error) {
	query := `
		SELECT id, name, bank_code, npsn, domain, address, phone, email, logo_url, created_at, updated_at, deleted_at
		FROM tenants WHERE deleted_at IS NULL ORDER BY created_at ASC LIMIT 1
	`
	row := r.queryRow(ctx, query)
	var tenant domain.Tenant
	err := row.Scan(
		&tenant.ID, &tenant.Name, &tenant.BankCode, &tenant.NPSN, &tenant.Domain, &tenant.Address,
		&tenant.Phone, &tenant.Email, &tenant.LogoURL, &tenant.CreatedAt,
		&tenant.UpdatedAt, &tenant.DeletedAt,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	return &tenant, nil
}

func (r *coreRepository) CreateRole(ctx context.Context, role *domain.Role) error {
	role.ID = uuid.New()
	role.CreatedAt = time.Now()
	query := `
		INSERT INTO roles (id, tenant_id, name, is_custom, created_at)
		VALUES (?, ?, ?, ?, ?)
	`
	_, err := r.exec(ctx, query, role.ID, role.TenantID, role.Name, role.IsCustom, role.CreatedAt)
	return err
}

func (r *coreRepository) GetRolesByTenantID(ctx context.Context, tenantID uuid.UUID) ([]*domain.Role, error) {
	query := `
		SELECT id, tenant_id, name, is_custom, created_at, updated_at
		FROM roles WHERE tenant_id = ? OR tenant_id IS NULL
	`
	rows, err := r.db.QueryContext(ctx, query, tenantID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var roles []*domain.Role
	for rows.Next() {
		var role domain.Role
		if err := rows.Scan(&role.ID, &role.TenantID, &role.Name, &role.IsCustom, &role.CreatedAt, &role.UpdatedAt); err != nil {
			return nil, err
		}
		roles = append(roles, &role)
	}

	return roles, nil
}

func (r *coreRepository) AssignPermissionToRole(ctx context.Context, roleID uuid.UUID, permissionID string) error {
	query := `INSERT INTO role_permissions (role_id, permission_id) VALUES (?, ?)`
	_, err := r.db.ExecContext(ctx, query, roleID, permissionID)
	if err != nil {
		return err
	}
	// Increment the role's permission version so all users with this role
	// will have their cache invalidated on next request.
	versionKey := fmt.Sprintf("role_perms_version:%s", roleID.String())
	if r.cache != nil {
		currVer, _ := r.cache.Get(ctx, versionKey)
		newVer := incrementVersion(currVer)
		_ = r.cache.Set(ctx, versionKey, newVer, 24*time.Hour)
	}
	return nil
}

func (r *coreRepository) GetSystemPermissions(ctx context.Context) ([]*domain.Permission, error) {
	query := `SELECT id, name FROM permissions ORDER BY id ASC`
	rows, err := r.db.QueryContext(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var permissions []*domain.Permission
	for rows.Next() {
		var p domain.Permission
		if err := rows.Scan(&p.ID, &p.Name); err != nil {
			return nil, err
		}
		permissions = append(permissions, &p)
	}
	return permissions, nil
}

func (r *coreRepository) GetRoleByNameAndTenant(ctx context.Context, roleName string, tenantID uuid.UUID) (*domain.Role, error) {
	query := `
		SELECT id, tenant_id, name, is_custom, created_at, updated_at
		FROM roles WHERE name = ? AND (tenant_id = ? OR tenant_id IS NULL)
		LIMIT 1
	`
	row := r.queryRow(ctx, query, roleName, tenantID)
	var role domain.Role
	err := row.Scan(&role.ID, &role.TenantID, &role.Name, &role.IsCustom, &role.CreatedAt, &role.UpdatedAt)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	return &role, nil
}

func (r *coreRepository) CreateUser(ctx context.Context, user *domain.User) error {
	// Hash password with bcrypt before storing — never store plaintext.
	hashed, err := bcrypt.GenerateFromPassword([]byte(user.Password), bcrypt.DefaultCost)
	if err != nil {
		return err
	}

	// Fetch tenant's bank_code to build the 12-digit account number
	tenant, err := r.GetTenantByID(context.Background(), user.TenantID)
	if err != nil || tenant == nil {
		return fmt.Errorf("tenant not found for account number generation")
	}

	// Generate unique 12-digit account number (retry on collision)
	var accountNumber string
	for i := 0; i < 10; i++ {
		accountNumber = generateAccountNumber(tenant.BankCode)
		var existing string
		err := r.db.QueryRowContext(context.Background(), "SELECT account_number FROM users WHERE account_number = ?", accountNumber).Scan(&existing)
		if err == sql.ErrNoRows {
			break // unique, use this
		}
	}
	user.AccountNumber = accountNumber
	user.ID = uuid.New()

	query := `
		INSERT INTO users (id, tenant_id, account_number, category, name, email, password_hash)
		VALUES (?, ?, ?, ?, ?, ?, ?)
	`
	_, err = r.exec(ctx, query, user.ID, user.TenantID, user.AccountNumber, user.Category, user.Name, user.Email, string(hashed))
	return err
}

func (r *coreRepository) AssignRoleToUser(ctx context.Context, userID, roleID uuid.UUID) error {
	query := `
		INSERT IGNORE INTO user_roles (user_id, role_id)
		VALUES (?, ?)
	`
	_, err := r.exec(ctx, query, userID, roleID)
	if err != nil {
		return err
	}
	// Invalidate user's cached role and permissions immediately.
	r.invalidateUserCache(ctx, userID)
	return nil
}

func (r *coreRepository) GetUserByEmail(ctx context.Context, email string) (*domain.User, error) {
	query := `
		SELECT id, tenant_id, category, name, email, phone, address, avatar_url, password_hash, created_at
		FROM users WHERE email = ? AND deleted_at IS NULL
		LIMIT 1
	`
	var user domain.User
	err := r.db.QueryRowContext(ctx, query, email).Scan(
		&user.ID, &user.TenantID, &user.Category, &user.Name, &user.Email, &user.Phone, &user.Address, &user.AvatarURL, &user.Password, &user.CreatedAt,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	return &user, nil
}

func (r *coreRepository) GetUserByID(ctx context.Context, id uuid.UUID) (*domain.User, error) {
	query := `
		SELECT id, tenant_id, account_number, category, name, email, phone, address, avatar_url, password_hash, COALESCE(pin_hash, ''), created_at
		FROM users WHERE id = ? AND deleted_at IS NULL
	`
	var user domain.User
	err := r.db.QueryRowContext(ctx, query, id).Scan(
		&user.ID, &user.TenantID, &user.AccountNumber, &user.Category, &user.Name, &user.Email, &user.Phone, &user.Address, &user.AvatarURL, &user.Password, &user.PinHash, &user.CreatedAt,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	return &user, nil
}

func (r *coreRepository) GetUserByAccountNumber(ctx context.Context, accountNumber string) (*domain.User, error) {
	query := `
		SELECT id, tenant_id, account_number, category, name, email, phone, address, avatar_url, password_hash, COALESCE(pin_hash, ''), created_at
		FROM users WHERE account_number = ? AND deleted_at IS NULL
	`
	var user domain.User
	err := r.db.QueryRowContext(ctx, query, accountNumber).Scan(
		&user.ID, &user.TenantID, &user.AccountNumber, &user.Category, &user.Name, &user.Email, &user.Phone, &user.Address, &user.AvatarURL, &user.Password, &user.PinHash, &user.CreatedAt,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	return &user, nil
}

func (r *coreRepository) GetUserByRFID(ctx context.Context, rfidTag string) (*domain.User, error) {
	query := `
		SELECT id, tenant_id, account_number, category, name, email, phone, address, avatar_url, password_hash, COALESCE(pin_hash, ''), created_at
		FROM users WHERE rfid_tag = ? AND deleted_at IS NULL
	`
	var user domain.User
	err := r.db.QueryRowContext(ctx, query, rfidTag).Scan(
		&user.ID, &user.TenantID, &user.AccountNumber, &user.Category, &user.Name, &user.Email, &user.Phone, &user.Address, &user.AvatarURL, &user.Password, &user.PinHash, &user.CreatedAt,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	return &user, nil
}

func (r *coreRepository) UpdateUserProfile(ctx context.Context, user *domain.User) error {
	query := `
		UPDATE users 
		SET name = ?, phone = ?, address = ?, avatar_url = ?, updated_at = NOW()
		WHERE id = ? AND deleted_at IS NULL
	`
	_, err := r.exec(ctx, query, user.Name, user.Phone, user.Address, user.AvatarURL, user.ID)
	return err
}

// GetUserRoleName returns the role name for a user, using versioned cache.
func (r *coreRepository) GetUserRoleName(ctx context.Context, userID uuid.UUID) (string, error) {
	if r.cache != nil {
		ver := r.cacheVersion(ctx, fmt.Sprintf("role_version:%s", userID.String()))
		cacheKey := fmt.Sprintf("role:%s:v%s", userID.String(), ver)
		if val, err := r.cache.Get(ctx, cacheKey); err == nil && val != "" {
			return val, nil
		}
	}

	query := `
		SELECT r.name
		FROM roles r
		JOIN user_roles ur ON r.id = ur.role_id
		WHERE ur.user_id = ?
		ORDER BY ur.role_id
		LIMIT 1
	`
	var roleName string
	err := r.db.QueryRowContext(ctx, query, userID).Scan(&roleName)
	if err != nil {
		if err == sql.ErrNoRows {
			return "", nil
		}
		return "", err
	}

	if r.cache != nil && roleName != "" {
		ver := r.cacheVersion(ctx, fmt.Sprintf("role_version:%s", userID.String()))
		cacheKey := fmt.Sprintf("role:%s:v%s", userID.String(), ver)
		_ = r.cache.Set(ctx, cacheKey, roleName, 15*time.Minute)
	}
	return roleName, nil
}

// GetUserPermissions returns all permissions for a user, using versioned cache.
func (r *coreRepository) GetUserPermissions(ctx context.Context, userID uuid.UUID) ([]string, error) {
	if r.cache != nil {
		ver := r.cacheVersion(ctx, fmt.Sprintf("perms_version:%s", userID.String()))
		cacheKey := fmt.Sprintf("perms:%s:v%s", userID.String(), ver)
		if val, err := r.cache.Get(ctx, cacheKey); err == nil && val != "" {
			var cachedPerms []string
			if err := json.Unmarshal([]byte(val), &cachedPerms); err == nil {
				return cachedPerms, nil
			}
		}
	}

	query := `
		SELECT DISTINCT rp.permission_id
		FROM user_roles ur
		JOIN role_permissions rp ON ur.role_id = rp.role_id
		WHERE ur.user_id = ?
	`
	rows, err := r.db.QueryContext(ctx, query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var permissions []string
	for rows.Next() {
		var p string
		if err := rows.Scan(&p); err != nil {
			return nil, err
		}
		permissions = append(permissions, p)
	}

	if r.cache != nil && len(permissions) > 0 {
		ver := r.cacheVersion(ctx, fmt.Sprintf("perms_version:%s", userID.String()))
		cacheKey := fmt.Sprintf("perms:%s:v%s", userID.String(), ver)
		if b, err := json.Marshal(permissions); err == nil {
			_ = r.cache.Set(ctx, cacheKey, string(b), 15*time.Minute)
		}
	}
	return permissions, nil
}

// cacheVersion gets the current version string for a given version key.
// If the version does not exist yet, it initialises it to "1".
func (r *coreRepository) cacheVersion(ctx context.Context, versionKey string) string {
	if r.cache == nil {
		return "1"
	}
	ver, err := r.cache.Get(ctx, versionKey)
	if err != nil || ver == "" {
		_ = r.cache.Set(ctx, versionKey, "1", 24*time.Hour)
		return "1"
	}
	return ver
}

// invalidateUserCache bumps both the role and permissions version numbers for a user
// so that the next request will bypass old cache entries and fetch fresh data.
// Old versioned keys are deliberately left to expire naturally via TTL — no costly scan needed.
func (r *coreRepository) invalidateUserCache(ctx context.Context, userID uuid.UUID) {
	if r.cache == nil {
		return
	}
	for _, prefix := range []string{"role_version", "perms_version"} {
		versionKey := fmt.Sprintf("%s:%s", prefix, userID.String())
		currVer, _ := r.cache.Get(ctx, versionKey)
		newVer := incrementVersion(currVer)
		_ = r.cache.Set(ctx, versionKey, newVer, 24*time.Hour)
	}
}

// incrementVersion converts a version string to integer, increments it, and returns a string.
func incrementVersion(ver string) string {
	v, err := strconv.Atoi(ver)
	if err != nil {
		return "1"
	}
	return strconv.Itoa(v + 1)
}

// UpdatePublicKey stores a user's E2EE public key for client-side encryption.
// Called on first login on a new device after key generation.
func (r *coreRepository) UpdatePublicKey(ctx context.Context, userID uuid.UUID, publicKey string) error {
	query := `UPDATE users SET public_key = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2`
	_, err := r.db.ExecContext(ctx, query, publicKey, userID)
	return err
}

func (r *coreRepository) CheckSpmbCompleted(ctx context.Context, parentID uuid.UUID) (bool, error) {
	query := `SELECT COUNT(*) FROM spmb_registrations WHERE parent_id = ? AND registration_status = 'ACCEPTED'`
	var count int
	err := r.db.QueryRowContext(ctx, query, parentID).Scan(&count)
	if err != nil {
		return false, err
	}
	return count > 0, nil
}
