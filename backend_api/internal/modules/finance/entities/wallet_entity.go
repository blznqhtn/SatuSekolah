package entities

import (
	"time"

	"github.com/google/uuid"
)

type PayoutMethod struct {
	ID            uuid.UUID `json:"id"`
	UserID        uuid.UUID `json:"user_id"`
	ProviderName  string    `json:"provider_name"`
	AccountNumber string    `json:"account_number"`
	AccountName   string    `json:"account_name"`
	IsPrimary     bool      `json:"is_primary"`
	CreatedAt     time.Time `json:"created_at"`
	UpdatedAt     time.Time `json:"updated_at"`
}

type TransactionType string

const (
	Credit TransactionType = "CREDIT"
	Debit  TransactionType = "DEBIT"
)

type WalletLedger struct {
	ID             uuid.UUID       `json:"id"`
	TenantID       uuid.UUID       `json:"tenant_id"`
	UserID         uuid.UUID       `json:"user_id"`
	TransactionType TransactionType `json:"transaction_type"`
	Amount         float64         `json:"amount"`
	Fee            float64         `json:"fee"`
	ReferenceType  string          `json:"reference_type"`
	ReferenceID    uuid.UUID       `json:"reference_id"`
	PreviousHash   string          `json:"previous_hash"`
	CurrentHash    string          `json:"current_hash"`
	CreatedAt      time.Time       `json:"created_at"`
}
