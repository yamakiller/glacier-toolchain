package cache

import (
	"context"
	"github.com/yamakiller/glacier-toolchain/http/request"
	"time"
)

var (
	_cache ICache
)

// Instance 全局缓存对象, 默认使用
func Instance() ICache {
	if _cache == nil {
		panic("global cache instance is nil")
	}
	return _cache
}

// SetGlobal 设置全局缓存
func SetGlobal(c ICache) {
	_cache = c
}

// NewListKeyResponse 实例化ListKeyResponse
func NewListKeyResponse(keys []string, total uint64) *ListKeyResponse {
	return &ListKeyResponse{
		Keys:  keys,
		Total: total,
	}
}

// ICache provides the interface for cache implementations.
type ICache interface {
	ListKey(*ListKeyRequest) (*ListKeyResponse, error)
	//SetDefaultTTL 设置默认TTL时间戳
	SetDefaultTTL(ttl time.Duration)
	//Put set cached value with key and expire time.
	Put(key string, val interface{}) error
	//PutWithTTL set cached value with key and expire time.
	PutWithTTL(key string, val interface{}, ttl time.Duration) error
	//Get 返回缓存中Key指定的Value
	Get(key string, val interface{}) error
	//Delete 删除缓冲区Key指定的Value.
	Delete(key string) error
	//IsExist 检测指定Key的Value再缓冲区中是否存在.
	IsExist(key string) bool
	//Clear 清除所有缓存.
	Clear() error
	//Incr 按键增加缓存的int值，作为计数器.
	Incr(key string) error
	//Decr 按键减少缓存的int值，作为计数器.
	Decr(key string) error
	//Close 关闭缓存.
	Close() error
	//WithContext 设置上下文
	WithContext(ctx context.Context) ICache
}

// ListKeyRequest  ...
type ListKeyRequest struct {
	pattern string
	*request.PageRequest
}

// Pattern ...
func (req *ListKeyRequest) Pattern() string {
	return req.pattern
}

// ListKeyResponse ...
type ListKeyResponse struct {
	Keys  []string
	Total uint64
}
