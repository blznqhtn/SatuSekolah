package usecase

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"time"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/inventory/domain"
	pkgDomain "neuracakrawira.asia/satu-sekolah-backend/internal/modules/pkg/domain"
	"neuracakrawira.asia/satu-sekolah-backend/pkg/cache"
)

type inventoryUsecase struct {
	repo       domain.InventoryRepository
	cache      cache.Cache
	pkgUsecase pkgDomain.PkgUsecase
}

func NewInventoryUsecase(repo domain.InventoryRepository, cache cache.Cache, pkgUsecase pkgDomain.PkgUsecase) domain.InventoryUsecase {
	return &inventoryUsecase{
		repo:       repo,
		cache:      cache,
		pkgUsecase: pkgUsecase,
	}
}

func (u *inventoryUsecase) getCacheKey(tenantID uuid.UUID) string {
	return fmt.Sprintf("inventory:items:%s", tenantID.String())
}

func (u *inventoryUsecase) GetItems(ctx context.Context, tenantID uuid.UUID) ([]*domain.InventoryItem, error) {
	cacheKey := u.getCacheKey(tenantID)
	cachedData, err := u.cache.Get(ctx, cacheKey)
	if err == nil && cachedData != "" {
		var items []*domain.InventoryItem
		if err := json.Unmarshal([]byte(cachedData), &items); err == nil {
			return items, nil
		}
	}

	// Cache miss or error
	items, err := u.repo.GetItemsByTenant(ctx, tenantID)
	if err != nil {
		return nil, err
	}

	// Set cache asynchronously or synchronously
	if itemsJSON, err := json.Marshal(items); err == nil {
		_ = u.cache.Set(ctx, cacheKey, string(itemsJSON), 24*time.Hour) // Cache for 24h
	}

	return items, nil
}

func (u *inventoryUsecase) CreateItem(ctx context.Context, item *domain.InventoryItem) error {
	if item.Name == "" {
		return errors.New("name is required")
	}

	if err := u.repo.CreateItem(ctx, item); err != nil {
		return err
	}

	// Invalidate cache
	_ = u.cache.Delete(ctx, u.getCacheKey(item.TenantID))
	return nil
}

func (u *inventoryUsecase) ReportCondition(ctx context.Context, report *domain.InventoryReport, stock int) error {
	if report.ItemID == uuid.Nil {
		return errors.New("item_id is required")
	}

	// Start a transaction for inventory updates
	err := u.repo.ExecTx(ctx, func(txRepo domain.InventoryRepository) error {
		// 1. Get the item to ensure it exists
		item, err := txRepo.GetItemByID(ctx, report.ItemID)
		if err != nil {
			return err
		}
		if item == nil {
			return errors.New("item not found")
		}

		// 2. Save the report
		if err := txRepo.CreateReport(ctx, report); err != nil {
			return err
		}

		// 3. Update the item's condition and stock
		if err := txRepo.UpdateItemConditionAndStock(ctx, report.ItemID, report.Condition, stock); err != nil {
			return err
		}

		return nil
	})

	if err != nil {
		return err
	}

	// Invalidate cache after successful update
	_ = u.cache.Delete(ctx, u.getCacheKey(report.TenantID))

	// 4. Auto-submit to PKG
	if u.pkgUsecase != nil && report.DocumentURL != "" {
		// Find active period
		activePeriod, err := u.pkgUsecase.GetActivePeriod(ctx, report.TenantID)
		if err == nil && activePeriod != nil {
			// Find "Laporan Inventaris" indicator
			indicators, err := u.pkgUsecase.GetIndicators(ctx, report.TenantID)
			if err == nil {
				var indicatorID uuid.UUID
				for _, ind := range indicators {
					if ind.Name == "Laporan Inventaris" {
						indicatorID = ind.ID
						break
					}
				}

				// If not found, create it automatically
				if indicatorID == uuid.Nil {
					newInd := &pkgDomain.PkgIndicator{
						TenantID:          report.TenantID,
						Name:              "Laporan Inventaris",
						Description:       "Auto-generated indicator for inventory management",
						Weight:            1.0,
						IsApplicableToAll: false, // only applies to staff assigned
					}
					if err := u.pkgUsecase.CreateIndicator(ctx, newInd); err == nil {
						indicatorID = newInd.ID
					}
				}

				// Submit document
				if indicatorID != uuid.Nil {
					pkgSub := &pkgDomain.PkgSubmission{
						PeriodID:    activePeriod.ID,
						IndicatorID: indicatorID,
						StaffID:     report.StaffID,
						DocumentURL: report.DocumentURL,
						Description: fmt.Sprintf("Laporan kondisi inventaris: %s", report.Notes),
						SubmittedAt: time.Now(),
					}
					// Ignore error for auto-submit since inventory update already succeeded
					_ = u.pkgUsecase.SubmitDocument(ctx, pkgSub)
				}
			}
		}
	}

	return nil
}
