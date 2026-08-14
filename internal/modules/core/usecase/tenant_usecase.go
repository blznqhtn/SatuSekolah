package usecase

import (
	"context"
	"errors"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/core/domain"
)

type coreUsecase struct {
	repo domain.CoreRepository
}

// NewCoreUsecase creates a new instance of CoreUsecase
func NewCoreUsecase(repo domain.CoreRepository) domain.CoreUsecase {
	return &coreUsecase{
		repo: repo,
	}
}

func (u *coreUsecase) RegisterNewTenant(ctx context.Context, req *domain.RegisterTenantRequest) (*domain.Tenant, error) {
	tenant := &domain.Tenant{
		Name:   req.TenantName,
		Domain: &req.TenantDomain,
	}

	err := u.repo.ExecTx(ctx, func(txRepo domain.CoreRepository) error {
		// 1. Create Tenant
		if err := txRepo.CreateTenant(ctx, tenant); err != nil {
			return err
		}

		// 2. Create 4 Default Roles for this tenant (is_custom = false)
		defaultRoles := []string{"Admin", "Staff", "Student", "Parent"}
		for _, rName := range defaultRoles {
			role := &domain.Role{
				TenantID: &tenant.ID,
				Name:     rName,
				IsCustom: false,
			}
			if err := txRepo.CreateRole(ctx, role); err != nil {
				return err
			}
		}

		// 3. Get Admin Role ID
		adminRole, err := txRepo.GetRoleByNameAndTenant(ctx, "Admin", tenant.ID)
		if err != nil {
			return err
		}
		if adminRole == nil {
			return errors.New("admin role not found after creation")
		}

		// 4. Create Admin User (password should be hashed with bcrypt before saving)
		adminUser := &domain.User{
			TenantID: tenant.ID,
			Category: "admin",
			Name:     req.AdminName,
			Email:    req.AdminEmail,
			Password: req.AdminPassword,
		}
		if err := txRepo.CreateUser(ctx, adminUser); err != nil {
			return err
		}

		// 5. Assign Admin Role to the newly created admin user
		if err := txRepo.AssignRoleToUser(ctx, adminUser.ID, adminRole.ID); err != nil {
			return err
		}

		return nil
	})

	if err != nil {
		return nil, err
	}

	return tenant, nil
}

func (u *coreUsecase) GetTenantProfile(ctx context.Context, id uuid.UUID) (*domain.Tenant, error) {
	return u.repo.GetTenantByID(ctx, id)
}

// CreateRole creates a single custom role for a tenant.
// This is called from the admin dashboard, not during tenant registration.
func (uc *coreUsecase) CreateRole(ctx context.Context, tenantID uuid.UUID, name string) error {
	role := &domain.Role{
		ID:       uuid.New(),
		TenantID: &tenantID,
		Name:     name,
		IsCustom: true,
	}
	return uc.repo.CreateRole(ctx, role)
}

func (uc *coreUsecase) GetSystemPermissions(ctx context.Context) ([]*domain.Permission, error) {
	return uc.repo.GetSystemPermissions(ctx)
}

func (uc *coreUsecase) GetFaqs(ctx context.Context) ([]*domain.Faq, error) {
	return uc.repo.GetFaqs(ctx)
}
