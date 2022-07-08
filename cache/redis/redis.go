package redis

import (
	"context"
	"encoding/json"
	"fmt"
	"github.com/go-redis/redis"
	"github.com/yamakiller/glacier-toolchain/cache"
	"github.com/yamakiller/glacier-toolchain/trace/tredis"
	"time"
)

// Cache 缓存
type Cache struct {
	_prefix string
	_ttl    time.Duration
	_client *redis.Client
}

// WithContext 启用上下文, 方便trace(redis).
func (c *Cache) WithContext(ctx context.Context) cache.ICache {
	clone := *c
	clone._client = tredis.WrapRedisClient(ctx, c._client)
	return &clone
}

// SetDefaultTTL 设置默认TTL时间戳(redis).
func (c *Cache) SetDefaultTTL(ttl time.Duration) {
	c._ttl = ttl
}

// PutWithTTL 推送Kev => Value 并设置TTL时间戳(redis).
func (c *Cache) PutWithTTL(key string, val interface{}, ttl time.Duration) error {
	b, err := json.Marshal(val)
	if err != nil {
		return err
	}

	if err := c._client.Set(key, b, ttl).Err(); err != nil {
		return err
	}

	return nil
}

// Put 推送Key=>Value使用默认TTL时间戳(redis).
func (c *Cache) Put(key string, val interface{}) error {
	return c.PutWithTTL(key, val, c._ttl)
}

// Get 返回Kev=>Value(redis).
func (c *Cache) Get(key string, val interface{}) error {
	v, err := c._client.Get(key).Bytes()
	if err != nil {
		return err
	}

	if err := json.Unmarshal(v, val); err != nil {
		return err
	}

	return nil
}

// Delete 删除指定Key指定的Value(redis).
func (c *Cache) Delete(key string) error {
	if err := c._client.Del(key).Err(); err != nil {
		return err
	}

	return nil
}

// IsExist 检测指定Key的Value是否存在(redis).
func (c *Cache) IsExist(key string) bool {
	if ret := c._client.Exists(key).Val(); ret == 1 {
		return true
	}

	return false
}

// Clear 清除所有数据(redis).
func (c *Cache) Clear() error {
	return c._client.FlushDB().Err()
}

// ListKey 根据缓存Request返回缓存中的Response(redis).
func (c *Cache) ListKey(req *cache.ListKeyRequest) (*cache.ListKeyResponse, error) {
	fmt.Println(uint64(req.GetOffset()), req.Pattern(), int64(req.PageSize))
	ks, total, err := c._client.Scan(uint64(req.GetOffset()),
		req.Pattern(),
		int64(req.PageSize)).Result()
	if err != nil {
		return nil, err
	}
	return cache.NewListKeyResponse(ks, total), nil
}

// Decr 按键减少缓存的int值，作为计数器(redis).
func (c *Cache) Decr(key string) error {
	return c._client.Decr(key).Err()
}

// Incr 按键增加缓存的int值，作为计数器(redis).
func (c *Cache) Incr(key string) error {
	return c._client.Incr(key).Err()
}

// Close 关闭缓存(redis).
func (c *Cache) Close() error {
	return c._client.Close()
}
