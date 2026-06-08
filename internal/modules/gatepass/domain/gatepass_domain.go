package domain

import (
	"context"
	"time"

	"github.com/google/uuid"
)

type GatePassStatus string

const (
	GatePassPending  GatePassStatus = "PENDING"
	GatePassApproved GatePassStatus = "APPROVED"
	GatePassExited   GatePassStatus = "EXITED"
	GatePassReturned GatePassStatus = "RETURNED"
	GatePassRejected GatePassStatus = "REJECTED"
	GatePassOverdue  GatePassStatus = "OVERDUE"
)

type ApprovalStatus string

const (
	ApprovalPending  ApprovalStatus = "PENDING"
	ApprovalApproved ApprovalStatus = "APPROVED"
	ApprovalRejected ApprovalStatus = "REJECTED"
)

// GatePassSetting defines the multilevel approval chain for a tenant.
type GatePassSetting struct {
	ID                 uuid.UUID  `json:"id"`
	TenantID           uuid.UUID  `json:"tenant_id"`
	Level1RoleID       *uuid.UUID `json:"level_1_role_id"`
	Level2RoleID       *uuid.UUID `json:"level_2_role_id"`
	Level3RoleID       *uuid.UUID `json:"level_3_role_id"`
	MainApproverRoleID *uuid.UUID `json:"main_approver_role_id"`
	UpdatedAt          time.Time  `json:"updated_at"`
}

// GatePass represents a student's exit permit.
// exit_qr_token is generated when all approvers approve.
// return_qr_token is generated when the student scans exit_qr_token at the gate (like MRT).
type GatePass struct {
	ID                 uuid.UUID      `json:"id"`
	TenantID           uuid.UUID      `json:"tenant_id"`
	StudentID          uuid.UUID      `json:"student_id"`
	Reason             string         `json:"reason"`
	ExpectedExitTime   time.Time      `json:"expected_exit_time"`
	ExpectedReturnTime time.Time      `json:"expected_return_time"`
	ActualExitTime     *time.Time     `json:"actual_exit_time,omitempty"`
	ActualReturnTime   *time.Time     `json:"actual_return_time,omitempty"`
	ExitQRToken        string         `json:"exit_qr_token,omitempty"`
	ReturnQRToken      string         `json:"return_qr_token,omitempty"`
	Status             GatePassStatus `json:"status"`
	CreatedAt          time.Time      `json:"created_at"`
	UpdatedAt          time.Time      `json:"updated_at"`
	Approvals          []GatePassApproval `json:"approvals,omitempty"`
}

// GatePassApproval tracks one tier's approval status.
type GatePassApproval struct {
	ID             uuid.UUID      `json:"id"`
	GatePassID     uuid.UUID      `json:"gate_pass_id"`
	ApproverRoleID uuid.UUID      `json:"approver_role_id"`
	TierLevel      int            `json:"tier_level"`
	Status         ApprovalStatus `json:"status"`
	ApprovedBy     *uuid.UUID     `json:"approved_by,omitempty"`
	ApprovedAt     *time.Time     `json:"approved_at,omitempty"`
}

type GatePassRepository interface {
	ExecTx(ctx context.Context, fn func(repo GatePassRepository) error) error

	// Settings
	UpsertSetting(ctx context.Context, setting *GatePassSetting) error
	GetSetting(ctx context.Context, tenantID uuid.UUID) (*GatePassSetting, error)

	// Gate Pass CRUD
	CreateGatePass(ctx context.Context, pass *GatePass) error
	GetGatePassByID(ctx context.Context, id uuid.UUID) (*GatePass, error)
	GetGatePassByExitQR(ctx context.Context, exitQR string) (*GatePass, error)
	GetGatePassByReturnQR(ctx context.Context, returnQR string) (*GatePass, error)
	UpdateGatePass(ctx context.Context, pass *GatePass) error
	GetPendingOverdue(ctx context.Context) ([]*GatePass, error)

	// Approvals
	CreateApprovals(ctx context.Context, approvals []*GatePassApproval) error
	GetApprovals(ctx context.Context, gatePassID uuid.UUID) ([]*GatePassApproval, error)
	UpdateApproval(ctx context.Context, approvalID uuid.UUID, status ApprovalStatus, approvedBy uuid.UUID) error
}

type GatePassUsecase interface {
	ConfigureSetting(ctx context.Context, tenantID uuid.UUID, setting *GatePassSetting) error
	GetSetting(ctx context.Context, tenantID uuid.UUID) (*GatePassSetting, error)

	// Student: submit exit request
	SubmitRequest(ctx context.Context, tenantID, studentID uuid.UUID, reason string, exitTime, returnTime time.Time) (*GatePass, error)

	// Approver: approve or reject at their tier (or as main_approver override)
	ProcessApproval(ctx context.Context, tenantID, approverID uuid.UUID, gatePassID uuid.UUID, approve bool) error

	// Gate guard: scan exit QR → status EXITED, generate return QR
	ScanExitQR(ctx context.Context, token string) (*GatePass, error)

	// Gate guard: scan return QR → status RETURNED
	ScanReturnQR(ctx context.Context, token string) (*GatePass, error)
}
