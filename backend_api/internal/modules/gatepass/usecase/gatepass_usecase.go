package usecase

import (
	"context"
	"errors"
	"time"

	"github.com/google/uuid"
	coreDomain "neuracakrawira.asia/satu-sekolah-backend/internal/modules/core/domain"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/gatepass/domain"
)

type gatePassUsecase struct {
	repo     domain.GatePassRepository
	coreRepo coreDomain.CoreRepository
}

func NewGatePassUsecase(repo domain.GatePassRepository, coreRepo coreDomain.CoreRepository) domain.GatePassUsecase {
	return &gatePassUsecase{repo: repo, coreRepo: coreRepo}
}

func (u *gatePassUsecase) ConfigureSetting(ctx context.Context, tenantID uuid.UUID, setting *domain.GatePassSetting) error {
	setting.TenantID = tenantID
	return u.repo.UpsertSetting(ctx, setting)
}

func (u *gatePassUsecase) GetSetting(ctx context.Context, tenantID uuid.UUID) (*domain.GatePassSetting, error) {
	return u.repo.GetSetting(ctx, tenantID)
}

// SubmitRequest creates a gate pass and pre-creates approval rows for each configured tier.
func (u *gatePassUsecase) SubmitRequest(ctx context.Context, tenantID, studentID uuid.UUID, reason string, exitTime, returnTime time.Time) (*domain.GatePass, error) {
	setting, err := u.repo.GetSetting(ctx, tenantID)
	if err != nil {
		return nil, err
	}
	if setting == nil || setting.Level1RoleID == nil {
		return nil, errors.New("gate pass approval chain not configured by admin")
	}
	if exitTime.Before(time.Now()) {
		return nil, errors.New("exit time must be in the future")
	}
	if returnTime.Before(exitTime) {
		return nil, errors.New("return time must be after exit time")
	}

	pass := &domain.GatePass{
		TenantID:           tenantID,
		StudentID:          studentID,
		Reason:             reason,
		ExpectedExitTime:   exitTime,
		ExpectedReturnTime: returnTime,
		Status:             domain.GatePassPending,
	}

	var approvals []*domain.GatePassApproval

	err = u.repo.ExecTx(ctx, func(txRepo domain.GatePassRepository) error {
		if err := txRepo.CreateGatePass(ctx, pass); err != nil {
			return err
		}

		// Build approval tiers from settings (1 to 3)
		tiers := []*uuid.UUID{setting.Level1RoleID, setting.Level2RoleID, setting.Level3RoleID}
		for i, roleID := range tiers {
			if roleID == nil {
				continue
			}
			a := &domain.GatePassApproval{
				GatePassID:     pass.ID,
				ApproverRoleID: *roleID,
				TierLevel:      i + 1,
				Status:         domain.ApprovalPending,
			}
			approvals = append(approvals, a)
		}
		return txRepo.CreateApprovals(ctx, approvals)
	})
	if err != nil {
		return nil, err
	}

	pass.Approvals = make([]domain.GatePassApproval, len(approvals))
	for i, a := range approvals {
		pass.Approvals[i] = *a
	}
	return pass, nil
}

// ProcessApproval lets an approver approve or reject at their tier, or via main_approver override.
func (u *gatePassUsecase) ProcessApproval(ctx context.Context, tenantID, approverID uuid.UUID, gatePassID uuid.UUID, approve bool) error {
	// Fetch approver's role
	roleName, err := u.coreRepo.GetUserRoleName(ctx, approverID)
	if err != nil {
		return err
	}

	setting, err := u.repo.GetSetting(ctx, tenantID)
	if err != nil || setting == nil {
		return errors.New("gate pass settings not configured")
	}

	approvals, err := u.repo.GetApprovals(ctx, gatePassID)
	if err != nil {
		return err
	}

	pass, err := u.repo.GetGatePassByID(ctx, gatePassID)
	if err != nil || pass == nil {
		return errors.New("gate pass not found")
	}
	if pass.Status != domain.GatePassPending {
		return errors.New("gate pass is no longer pending")
	}

	// Resolve approver's role ID from coreRepo
	approverRole, err := u.coreRepo.GetRoleByNameAndTenant(ctx, roleName, tenantID)
	if err != nil || approverRole == nil {
		return errors.New("could not find approver role")
	}

	isMainApprover := setting.MainApproverRoleID != nil && approverRole.ID == *setting.MainApproverRoleID

	// Find the approval row that matches this role, or use main_approver override
	var targetApproval *domain.GatePassApproval
	for _, a := range approvals {
		if a.ApproverRoleID == approverRole.ID && a.Status == domain.ApprovalPending {
			targetApproval = a
			break
		}
	}

	// Main approver can approve any pending tier they don't own
	if targetApproval == nil && isMainApprover {
		for _, a := range approvals {
			if a.Status == domain.ApprovalPending {
				targetApproval = a
				break
			}
		}
	}

	if targetApproval == nil {
		return errors.New("no pending approval tier found for your role")
	}

	return u.repo.ExecTx(ctx, func(txRepo domain.GatePassRepository) error {
		newStatus := domain.ApprovalApproved
		if !approve {
			newStatus = domain.ApprovalRejected
		}

		if err := txRepo.UpdateApproval(ctx, targetApproval.ID, newStatus, approverID); err != nil {
			return err
		}

		// If rejected, mark gate pass as REJECTED
		if !approve {
			pass.Status = domain.GatePassRejected
			return txRepo.UpdateGatePass(ctx, pass)
		}

		// Reload approvals to check if all are approved
		refreshed, err := txRepo.GetApprovals(ctx, gatePassID)
		if err != nil {
			return err
		}
		allApproved := true
		for _, a := range refreshed {
			if a.ID == targetApproval.ID {
				continue // already updated above
			}
			if a.Status == domain.ApprovalPending {
				allApproved = false
				break
			}
		}

		// If all tiers approved → generate exit QR, mark APPROVED
		if allApproved {
			pass.Status = domain.GatePassApproved
			pass.ExitQRToken = "GATE-EXIT-" + gatePassID.String()[:8] + "-" + uuid.New().String()[:8]
			return txRepo.UpdateGatePass(ctx, pass)
		}
		return nil
	})
}

// ScanExitQR: Guard scans exit QR → status EXITED, generate return QR (like MRT tap-in).
func (u *gatePassUsecase) ScanExitQR(ctx context.Context, token string) (*domain.GatePass, error) {
	pass, err := u.repo.GetGatePassByExitQR(ctx, token)
	if err != nil {
		return nil, err
	}
	if pass == nil {
		return nil, errors.New("invalid exit QR token")
	}
	if pass.Status != domain.GatePassApproved {
		return nil, errors.New("gate pass is not in APPROVED state")
	}

	now := time.Now()
	pass.Status = domain.GatePassExited
	pass.ActualExitTime = &now
	// Generate return QR immediately (shown to student on their device after scan)
	pass.ReturnQRToken = "GATE-RETURN-" + pass.ID.String()[:8] + "-" + uuid.New().String()[:8]

	if err := u.repo.UpdateGatePass(ctx, pass); err != nil {
		return nil, err
	}
	return pass, nil
}

// ScanReturnQR: Guard scans return QR → status RETURNED.
func (u *gatePassUsecase) ScanReturnQR(ctx context.Context, token string) (*domain.GatePass, error) {
	pass, err := u.repo.GetGatePassByReturnQR(ctx, token)
	if err != nil {
		return nil, err
	}
	if pass == nil {
		return nil, errors.New("invalid return QR token")
	}
	if pass.Status != domain.GatePassExited {
		return nil, errors.New("gate pass has not been scanned at exit yet")
	}

	now := time.Now()
	pass.Status = domain.GatePassReturned
	pass.ActualReturnTime = &now

	if err := u.repo.UpdateGatePass(ctx, pass); err != nil {
		return nil, err
	}
	return pass, nil
}
