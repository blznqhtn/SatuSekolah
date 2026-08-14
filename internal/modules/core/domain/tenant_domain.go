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
	Phone         *string    `json:"phone"`
	Address       *string    `json:"address"`
	AvatarURL     *string    `json:"avatar_url"`
	Username      *string    `json:"username"`
	Nisn          *string    `json:"nisn"`
	Npk           *string    `json:"npk"`
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

type Faq struct {
	ID       string    `json:"id"`
	Question string    `json:"question"`
	Answer   string    `json:"answer"`
	Category string    `json:"category"`
	CreatedAt time.Time `json:"created_at"`
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
	GetFirstTenant(ctx context.Context) (*Tenant, error)
	
	CreateRole(ctx context.Context, role *Role) error
	GetRolesByTenantID(ctx context.Context, tenantID uuid.UUID) ([]*Role, error)
	GetRoleByNameAndTenant(ctx context.Context, roleName string, tenantID uuid.UUID) (*Role, error)
	AssignPermissionToRole(ctx context.Context, roleID uuid.UUID, permissionID string) error
	GetSystemPermissions(ctx context.Context) ([]*Permission, error)

	CreateUser(ctx context.Context, user *User) error
	AssignRoleToUser(ctx context.Context, userID, roleID uuid.UUID) error

	// Auth helpers
	GetUserByLoginIdentifier(ctx context.Context, identifier string) (*User, error)
	GetUserByID(ctx context.Context, id uuid.UUID) (*User, error)
	GetUserByAccountNumber(ctx context.Context, accountNumber string) (*User, error)
	GetUserByRFID(ctx context.Context, rfidTag string) (*User, error)
	UpdateUserProfile(ctx context.Context, user *User) error
	UpdatePublicKey(ctx context.Context, userID uuid.UUID, publicKey string) error
	GetUserRoleName(ctx context.Context, userID uuid.UUID) (string, error)
	GetUserPermissions(ctx context.Context, userID uuid.UUID) ([]string, error)
	CheckSpmbCompleted(ctx context.Context, parentID uuid.UUID) (bool, error)
	UpdateUserPassword(ctx context.Context, userID uuid.UUID, newPassword string) error
	GetNotificationSettings(ctx context.Context, userID uuid.UUID) (map[string]bool, error)
	UpdateNotificationSettings(ctx context.Context, userID uuid.UUID, settings map[string]bool) error
	GetFaqs(ctx context.Context) ([]*Faq, error)
	GetChildrenByParentID(ctx context.Context, parentID uuid.UUID) ([]*User, error)
}

// CoreUsecase defines the business logic interface for Tenants and RBAC
type CoreUsecase interface {
	RegisterNewTenant(ctx context.Context, req *RegisterTenantRequest) (*Tenant, error)
	GetTenantProfile(ctx context.Context, id uuid.UUID) (*Tenant, error)
	// CreateRole is called by the admin dashboard to add roles (Staff, Student, etc.)
	CreateRole(ctx context.Context, tenantID uuid.UUID, name string) error
	GetSystemPermissions(ctx context.Context) ([]*Permission, error)
	GetFaqs(ctx context.Context) ([]*Faq, error)
}
