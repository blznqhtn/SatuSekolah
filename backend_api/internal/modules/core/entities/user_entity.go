package entities

import (
	"database/sql"
	"time"

	"github.com/google/uuid"
)

type UserCategory string

const (
	Student UserCategory = "student"
	Staff UserCategory = "Staff"
	Parent  UserCategory = "parent"
	Admin   UserCategory = "admin"
)

type EnrollmentStatus string

const (
	Candidate EnrollmentStatus = "CANDIDATE"
	Active    EnrollmentStatus = "ACTIVE"
	Alumni    EnrollmentStatus = "ALUMNI"
	Suspended EnrollmentStatus = "SUSPENDED"
)

type User struct {
	ID               uuid.UUID        `json:"id"`
	TenantID         uuid.NullUUID    `json:"tenant_id"`
	ClassID          uuid.NullUUID    `json:"class_id"`
	Category         UserCategory     `json:"category"`
	EnrollmentStatus EnrollmentStatus `json:"enrollment_status"`
	Name             string           `json:"name"`
	Email            string           `json:"email"`
	Phone            sql.NullString   `json:"phone"`
	PasswordHash     string           `json:"-"`
	PinHash          sql.NullString   `json:"-"`
	Identifier       sql.NullString   `json:"identifier"`
	RfidTag          sql.NullString   `json:"rfid_tag"`
	FaceEncoding     sql.NullString   `json:"face_encoding"`
	WalletBalance    float64          `json:"wallet_balance"`
	PublicKey        sql.NullString   `json:"public_key"`
	ParentID         uuid.NullUUID    `json:"parent_id"`
	CreatedAt        time.Time        `json:"created_at"`
	UpdatedAt        sql.NullTime     `json:"updated_at"`
	DeletedAt        sql.NullTime     `json:"deleted_at"`
}

type UserRole struct {
	UserID uuid.UUID `json:"user_id"`
	RoleID uuid.UUID `json:"role_id"`
}
