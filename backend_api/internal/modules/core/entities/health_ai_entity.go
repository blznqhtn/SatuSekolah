package entities

import (
	"database/sql"
	"time"

	"github.com/google/uuid"
)

type HealthRecord struct {
	ID               uuid.UUID      `json:"id"`
	TenantID         uuid.UUID      `json:"tenant_id"`
	UserID           uuid.UUID      `json:"user_id"`
	RecordType       string         `json:"record_type"`
	Date             time.Time      `json:"date"`
	Notes            string         `json:"notes"`
	AIRecommendation sql.NullString `json:"ai_recommendation"`
	CreatedAt        time.Time      `json:"created_at"`
	UpdatedAt        sql.NullTime   `json:"updated_at"`
	UpdatedBy        uuid.UUID      `json:"updated_by"`
}

type AITenantQuota struct {
	TenantID         uuid.UUID    `json:"tenant_id"`
	TotalTokensLimit int64        `json:"total_tokens_limit"`
	TokensUsed       int64        `json:"tokens_used"`
	UpdatedAt        sql.NullTime `json:"updated_at"`
}
