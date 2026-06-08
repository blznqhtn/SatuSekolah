package cache

import (
	"context"
	"database/sql"
	"time"
)

type dbCache struct {
	db     *sql.DB
	driver string
}

// NewDBCache creates a new Cache implementation using Database.
func NewDBCache(db *sql.DB, driver string) Cache {
	return &dbCache{db: db, driver: driver}
}

func (c *dbCache) Set(ctx context.Context, key string, value string, ttl time.Duration) error {
	var expiresAt *time.Time
	if ttl > 0 {
		exp := time.Now().Add(ttl)
		expiresAt = &exp
	}

	var query string
	if c.driver == "postgres" {
		query = `
			INSERT INTO cache_store (key, value, expires_at)
			VALUES ($1, $2, $3)
			ON CONFLICT (key) DO UPDATE
			SET value = EXCLUDED.value,
				expires_at = EXCLUDED.expires_at
		`
		_, err := c.db.ExecContext(ctx, query, key, value, expiresAt)
		return err
	} else if c.driver == "mysql" {
		query = `
			INSERT INTO cache_store (key, value, expires_at)
			VALUES (?, ?, ?)
			ON DUPLICATE KEY UPDATE value = VALUES(value), expires_at = VALUES(expires_at)
		`
		_, err := c.db.ExecContext(ctx, query, key, value, expiresAt)
		return err
	} else {
		// SQLite
		query = `
			INSERT OR REPLACE INTO cache_store (key, value, expires_at)
			VALUES (?, ?, ?)
		`
		_, err := c.db.ExecContext(ctx, query, key, value, expiresAt)
		return err
	}
}

func (c *dbCache) Get(ctx context.Context, key string) (string, error) {
	var query string
	if c.driver == "postgres" {
		query = `
			SELECT value FROM cache_store
			WHERE key = $1 AND (expires_at IS NULL OR expires_at > CURRENT_TIMESTAMP)
		`
	} else {
		query = `
			SELECT value FROM cache_store
			WHERE key = ? AND (expires_at IS NULL OR expires_at > CURRENT_TIMESTAMP)
		`
	}

	var value string
	err := c.db.QueryRowContext(ctx, query, key).Scan(&value)
	if err == sql.ErrNoRows {
		return "", nil // cache miss is not an error
	}
	return value, err
}

func (c *dbCache) Delete(ctx context.Context, key string) error {
	var query string
	if c.driver == "postgres" {
		query = `DELETE FROM cache_store WHERE key = $1`
	} else {
		query = `DELETE FROM cache_store WHERE key = ?`
	}
	_, err := c.db.ExecContext(ctx, query, key)
	return err
}

// CleanupExpired purges all stale cache entries from the database cache_store.
// This is a no-op friendly function: if no rows expired, it returns nil.
func (c *dbCache) CleanupExpired(ctx context.Context) error {
	_, err := c.db.ExecContext(ctx, `DELETE FROM cache_store WHERE expires_at IS NOT NULL AND expires_at < CURRENT_TIMESTAMP`)
	return err
}
