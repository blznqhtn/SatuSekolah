package usecase

import (
	"context"
	"errors"
	"time"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/ai/domain"
)

type aiModuleUsecase struct {
	repo domain.AIRepository
}

func NewAIModuleUsecase(repo domain.AIRepository) domain.AIModuleUsecase {
	return &aiModuleUsecase{repo: repo}
}

// ListModuleSettings returns all configured AI module settings for a tenant.
// Modules that have no row yet are added as default (inactive, no limit) so the
// frontend always receives a full, predictable list.
func (u *aiModuleUsecase) ListModuleSettings(ctx context.Context, tenantID uuid.UUID) ([]*domain.AIModuleSetting, error) {
	existing, err := u.repo.GetAllModuleSettings(ctx, tenantID)
	if err != nil {
		return nil, err
	}

	// Build a lookup map from existing DB rows
	existingMap := make(map[string]*domain.AIModuleSetting, len(existing))
	for _, s := range existing {
		existingMap[s.ModuleName] = s
	}

	// Ensure every known module appears in the result
	result := make([]*domain.AIModuleSetting, 0, len(domain.KnownAIModules))
	for _, mod := range domain.KnownAIModules {
		if s, ok := existingMap[mod]; ok {
			result = append(result, s)
		} else {
			// Return a sensible default — not yet persisted
			result = append(result, &domain.AIModuleSetting{
				TenantID:     tenantID,
				ModuleName:   mod,
				IsActive:     false,
				MonthlyLimit: 0,
				DailyLimit:   0,
				MonthlyUsed:  0,
				DailyUsed:    0,
			})
		}
	}
	return result, nil
}

// UpdateModuleSetting lets an authorized user (MANAGE_AI permission or Admin) update
// a module's AI activation status and usage limits.
func (u *aiModuleUsecase) UpdateModuleSetting(
	ctx context.Context,
	requesterID, tenantID uuid.UUID,
	moduleName string,
	isActive bool,
	dailyLimit, monthlyLimit int,
) (*domain.AIModuleSetting, error) {
	// Validate permission
	allowed, err := u.repo.HasPermission(ctx, requesterID, "MANAGE_AI")
	if err != nil {
		return nil, err
	}
	if !allowed {
		return nil, errors.New("forbidden: MANAGE_AI permission is required")
	}

	// Validate module name
	valid := false
	for _, m := range domain.KnownAIModules {
		if m == moduleName {
			valid = true
			break
		}
	}
	if !valid {
		return nil, errors.New("unknown AI module: " + moduleName +
			". Valid modules: " + joinModules(domain.KnownAIModules))
	}

	if dailyLimit < 0 || monthlyLimit < 0 {
		return nil, errors.New("limits cannot be negative (use 0 for unlimited)")
	}

	// Load existing or build new
	existing, _ := u.repo.GetModuleSetting(ctx, tenantID, moduleName)
	if existing == nil {
		existing = &domain.AIModuleSetting{
			TenantID:    tenantID,
			ModuleName:  moduleName,
			MonthlyUsed: 0,
			DailyUsed:   0,
		}
	}

	existing.IsActive = isActive
	existing.DailyLimit = dailyLimit
	existing.MonthlyLimit = monthlyLimit

	if err := u.repo.SetModuleSetting(ctx, existing); err != nil {
		return nil, err
	}
	return existing, nil
}

// CheckModuleAllowed verifies:
//  1. The module is active for this tenant.
//  2. Daily usage hasn't exceeded daily_limit (if > 0).
//  3. Monthly usage hasn't exceeded monthly_limit (if > 0).
//
// It auto-resets daily_used when the date changes (handled in IncrementModuleUsage at DB level).
func (u *aiModuleUsecase) CheckModuleAllowed(ctx context.Context, tenantID uuid.UUID, moduleName string) (*domain.AIModuleCheckResult, error) {
	setting, err := u.repo.GetModuleSetting(ctx, tenantID, moduleName)
	if err != nil {
		return nil, err
	}

	if setting == nil || !setting.IsActive {
		return &domain.AIModuleCheckResult{
			Allowed: false,
			Reason:  "AI is not enabled for module '" + moduleName + "' on this tenant",
		}, nil
	}

	now := time.Now()

	// Check if daily reset needed (compare date only)
	dailyUsed := setting.DailyUsed
	if setting.LastResetDate != nil && !isSameDay(*setting.LastResetDate, now) {
		dailyUsed = 0
	}

	// Monthly reset check
	monthlyUsed := setting.MonthlyUsed
	if setting.LastResetDate != nil && !isSameMonth(*setting.LastResetDate, now) {
		monthlyUsed = 0
	}

	if setting.DailyLimit > 0 && dailyUsed >= setting.DailyLimit {
		return &domain.AIModuleCheckResult{
			Allowed:      false,
			Reason:       "Daily AI usage limit reached for module '" + moduleName + "'",
			DailyUsed:    dailyUsed,
			DailyLimit:   setting.DailyLimit,
			MonthlyUsed:  monthlyUsed,
			MonthlyLimit: setting.MonthlyLimit,
		}, nil
	}

	if setting.MonthlyLimit > 0 && monthlyUsed >= setting.MonthlyLimit {
		return &domain.AIModuleCheckResult{
			Allowed:      false,
			Reason:       "Monthly AI usage limit reached for module '" + moduleName + "'",
			DailyUsed:    dailyUsed,
			DailyLimit:   setting.DailyLimit,
			MonthlyUsed:  monthlyUsed,
			MonthlyLimit: setting.MonthlyLimit,
		}, nil
	}

	return &domain.AIModuleCheckResult{
		Allowed:      true,
		DailyUsed:    dailyUsed,
		DailyLimit:   setting.DailyLimit,
		MonthlyUsed:  monthlyUsed,
		MonthlyLimit: setting.MonthlyLimit,
	}, nil
}

// ConsumeModuleQuota increments the usage counters for a module after a successful AI call.
func (u *aiModuleUsecase) ConsumeModuleQuota(ctx context.Context, tenantID uuid.UUID, moduleName string) error {
	return u.repo.IncrementModuleUsage(ctx, tenantID, moduleName)
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

func isSameDay(a, b time.Time) bool {
	ay, am, ad := a.Date()
	by, bm, bd := b.Date()
	return ay == by && am == bm && ad == bd
}

func isSameMonth(a, b time.Time) bool {
	ay, am, _ := a.Date()
	by, bm, _ := b.Date()
	return ay == by && am == bm
}

func joinModules(modules []string) string {
	result := ""
	for i, m := range modules {
		if i > 0 {
			result += ", "
		}
		result += m
	}
	return result
}
