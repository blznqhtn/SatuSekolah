package cache

import (
	"context"
	"time"

	"github.com/redis/go-redis/v9"
)

type redisCache struct {
	client *redis.Client
}

// NewRedisCache creates a new Cache implementation using Redis.
func NewRedisCache(client *redis.Client) Cache {
	return &redisCache{client: client}
}

func (r *redisCache) Set(ctx context.Context, key string, value string, ttl time.Duration) error {
	return r.client.Set(ctx, key, value, ttl).Err()
}

func (r *redisCache) Get(ctx context.Context, key string) (string, error) {
	val, err := r.client.Get(ctx, key).Result()
	if err == redis.Nil {
		return "", nil // cache miss is not an error
	}
	return val, err
}

func (r *redisCache) Delete(ctx context.Context, key string) error {
	return r.client.Del(ctx, key).Err()
}

// CleanupExpired is a no-op for Redis since Redis handles TTL expiry natively.
func (r *redisCache) CleanupExpired(_ context.Context) error {
	return nil
}
