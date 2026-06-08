package entities

import (
	"database/sql"
	"time"

	"github.com/google/uuid"
)

type Tenant struct {
	ID        uuid.UUID      `json:"id"`
	Name      string         `json:"name"`
	NPSN      sql.NullString `json:"npsn"`
	Domain    string         `json:"domain"`
	Address   sql.NullString `json:"address"`
	Phone     sql.NullString `json:"phone"`
	Email     sql.NullString `json:"email"`
	LogoURL   sql.NullString `json:"logo_url"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt sql.NullTime   `json:"updated_at"`
	DeletedAt sql.NullTime   `json:"deleted_at"`
}
