package domain

import (
	"context"
	"time"

	"github.com/google/uuid"
)

// KnownAIModules is the registry of all features that support AI integration.
// Any new module that uses AI must be registered here.
var KnownAIModules = []string{
	"HEALTH",           // UKS: AI health record analysis & menstrual advice
	"CANTEEN",          // Kantin: AI business insight & monthly financial analysis
	"ACADEMIC_REPORT",  // Raport: AI narrative generation for report cards
	"VIOLATIONS",       // Kesiswaan: AI behavior pattern analysis
	"LIBRARY",          // Perpustakaan: AI reading recommendation
	"PKL",              // PKL: AI journal feedback for students
	"PORTFOLIO",        // Portofolio: AI extract data from LinkedIn PDF
}

type AITenantQuota struct {
	TenantID          uuid.UUID `json:"tenant_id"`
	TotalInputTokens  int64     `json:"total_input_tokens"`
	InputTokensUsed   int64     `json:"input_tokens_used"`
	TotalOutputTokens int64     `json:"total_output_tokens"`
	OutputTokensUsed  int64     `json:"output_tokens_used"`
	UpdatedAt         string    `json:"updated_at"`
}

// AIModuleSetting controls which features have AI enabled and their usage limits.
type AIModuleSetting struct {
	ID            uuid.UUID  `json:"id"`
	TenantID      uuid.UUID  `json:"tenant_id"`
	ModuleName    string     `json:"module_name"`
	IsActive      bool       `json:"is_active"`
	MonthlyLimit  int        `json:"monthly_limit"`  // 0 = unlimited
	DailyLimit    int        `json:"daily_limit"`    // 0 = unlimited
	MonthlyUsed   int        `json:"monthly_used"`
	DailyUsed     int        `json:"daily_used"`
	LastResetDate *time.Time `json:"last_reset_date,omitempty"`
	UpdatedAt     string     `json:"updated_at"`
}

// AIModuleCheckResult is returned when checking if a module's AI is allowed.
type AIModuleCheckResult struct {
	Allowed      bool   `json:"allowed"`
	Reason       string `json:"reason,omitempty"`
	DailyUsed    int    `json:"daily_used"`
	DailyLimit   int    `json:"daily_limit"`
	MonthlyUsed  int    `json:"monthly_used"`
	MonthlyLimit int    `json:"monthly_limit"`
}

type AIRepository interface {
	ExecTx(ctx context.Context, fn func(repo AIRepository) error) error

	GetQuota(ctx context.Context, tenantID uuid.UUID) (*AITenantQuota, error)
	AddTokensUsed(ctx context.Context, tenantID uuid.UUID, inputUsed, outputUsed int64) error
	TopupQuota(ctx context.Context, tenantID uuid.UUID, addInputTokens, addOutputTokens int64) error

	GetModuleSetting(ctx context.Context, tenantID uuid.UUID, moduleName string) (*AIModuleSetting, error)
	GetAllModuleSettings(ctx context.Context, tenantID uuid.UUID) ([]*AIModuleSetting, error)
	SetModuleSetting(ctx context.Context, setting *AIModuleSetting) error

	// IncrementModuleUsage increments daily and monthly counters, resetting daily if day changed.
	IncrementModuleUsage(ctx context.Context, tenantID uuid.UUID, moduleName string) error

	// HasPermission checks if a user (by ID) has a specific named permission.
	HasPermission(ctx context.Context, userID uuid.UUID, permissionName string) (bool, error)
}

type AIModuleUsecase interface {
	// ListModuleSettings returns all AI module settings for a tenant.
	// Modules not yet configured are returned with defaults (inactive, no limit).
	ListModuleSettings(ctx context.Context, tenantID uuid.UUID) ([]*AIModuleSetting, error)

	// UpdateModuleSetting lets an authorized user toggle a module and set limits.
	UpdateModuleSetting(ctx context.Context, requesterID, tenantID uuid.UUID, moduleName string, isActive bool, dailyLimit, monthlyLimit int) (*AIModuleSetting, error)

	// CheckModuleAllowed verifies quota and activation before an AI call is made.
	// It also handles auto-reset of daily counters.
	CheckModuleAllowed(ctx context.Context, tenantID uuid.UUID, moduleName string) (*AIModuleCheckResult, error)

	// ConsumeModuleQuota is called after a successful AI call to increment usage.
	ConsumeModuleQuota(ctx context.Context, tenantID uuid.UUID, moduleName string) error
}

type AIUsecase interface {
	// BuyTokens handles the midtrans checkout logic
	BuyTokens(ctx context.Context, tenantID uuid.UUID, tokenPackages int) (string, error)
	// ProcessWebhook handles the midtrans success callback
	ProcessPaymentSuccess(ctx context.Context, tenantID uuid.UUID, tokenPackages int) error
}
