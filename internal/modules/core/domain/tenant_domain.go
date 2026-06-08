package domain

import (
	"context"
	"time"

	"github.com/google/uuid"
)

// User represents a system user (needed here for Core Admin Creation)
type User struct {
	ID            uuid.UUID  `json:"id"`
	TenantID      uuid.UUID  `json:"tenant_id"`
	AccountNumber string     `json:"account_number"`
	Category      string     `json:"category"`
	Name          string     `json:"name"`
	Email         string     `json:"email"`
	Password      string     `json:"-"` // NEVER expose password hash in JSON responses
	PinHash       string     `json:"-"` // NEVER expose pin hash in JSON responses
	CreatedAt     time.Time  `json:"created_at"`
}

// Tenant represents the multi-tenant core structure
type Tenant struct {
	ID        uuid.UUID  `json:"id"`
	Name      string     `json:"name"`
	BankCode  string     `json:"-"` // Internal bank code, never expose in API
	NPSN      *string    `json:"npsn"`
	Domain    *string    `json:"domain"`
	Address   *string    `json:"address"`
	Phone     *string    `json:"phone"`
	Email     *string    `json:"email"`
	LogoURL   *string    `json:"logo_url"`
	CreatedAt time.Time  `json:"created_at"`
	UpdatedAt *time.Time `json:"updated_at"`
	DeletedAt *time.Time `json:"deleted_at"`
}

// Role represents RBAC role structure
type Role struct {
	ID        uuid.UUID  `json:"id"`
	TenantID  *uuid.UUID `json:"tenant_id"`
	Name      string     `json:"name"`
	IsCustom  bool       `json:"is_custom"`
	CreatedAt time.Time  `json:"created_at"`
	UpdatedAt *time.Time `json:"updated_at"`
}

// Permission represents granular permissions
type Permission struct {
	ID   string `json:"id"`
	Name string `json:"name"`
}

// RegisterTenantRequest is the payload from the web frontend
type RegisterTenantRequest struct {
	TenantName    string `json:"tenant_name"`
	TenantDomain  string `json:"tenant_domain"`
	AdminName     string `json:"admin_name"`
	AdminEmail    string `json:"admin_email"`
	AdminPassword string `json:"admin_password"`
}

// CoreRepository defines the data access interface for Tenants and RBAC
type CoreRepository interface {
	ExecTx(ctx context.Context, fn func(repo CoreRepository) error) error

	CreateTenant(ctx context.Context, tenant *Tenant) error
	GetTenantByID(ctx context.Context, id uuid.UUID) (*Tenant, error)
	GetTenantByDomain(ctx context.Context, domain string) (*Tenant, error)
	
	CreateRole(ctx context.Context, role *Role) error
	GetRolesByTenantID(ctx context.Context, tenantID uuid.UUID) ([]*Role, error)
	GetRoleByNameAndTenant(ctx context.Context, roleName string, tenantID uuid.UUID) (*Role, error)
	AssignPermissionToRole(ctx context.Context, roleID uuid.UUID, permissionID string) error
	GetSystemPermissions(ctx context.Context) ([]*Permission, error)

	CreateUser(ctx context.Context, user *User) error
	AssignRoleToUser(ctx context.Context, userID, roleID uuid.UUID) error

	// Auth helpers
	GetUserByEmail(ctx context.Context, email string) (*User, error)
	GetUserByID(ctx context.Context, id uuid.UUID) (*User, error)
	GetUserByAccountNumber(ctx context.Context, accountNumber string) (*User, error)
	GetUserByRFID(ctx context.Context, rfidTag string) (*User, error)
	UpdatePublicKey(ctx context.Context, userID uuid.UUID, publicKey string) error
	GetUserRoleName(ctx context.Context, userID uuid.UUID) (string, error)
	GetUserPermissions(ctx context.Context, userID uuid.UUID) ([]string, error)
}

// CoreUsecase defines the business logic interface for Tenants and RBAC
type CoreUsecase interface {
	RegisterNewTenant(ctx context.Context, req *RegisterTenantRequest) (*Tenant, error)
	GetTenantProfile(ctx context.Context, id uuid.UUID) (*Tenant, error)
	// CreateRole is called by the admin dashboard to add roles (Staff, Student, etc.)
	CreateRole(ctx context.Context, tenantID uuid.UUID, name string) error
	GetSystemPermissions(ctx context.Context) ([]*Permission, error)
}
