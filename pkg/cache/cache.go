package cache

import (
	"context"
	"database/sql"
	"time"

	"github.com/redis/go-redis/v9"
	"neuracakrawira.asia/satu-sekolah-backend/internal/config"
)

// Cache defines the contract for caching operations.
type Cache interface {
	Set(ctx context.Context, key string, value string, ttl time.Duration) error
	Get(ctx context.Context, key string) (string, error)
	Delete(ctx context.Context, key string) error
	// CleanupExpired purges stale entries (for DB driver only; no-op for Redis).
	CleanupExpired(ctx context.Context) error
}

// NewCache is a factory function that returns either a Redis or Database cache implementation.
func NewCache(cfg *config.Config, db *sql.DB, redisClient *redis.Client, dbDriver string) Cache {
	if cfg.App.CacheDriver == "redis" && redisClient != nil {
		return NewRedisCache(redisClient)
	}
	return NewDBCache(db, dbDriver)
}
