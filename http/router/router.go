package router

import (
	"fmt"
	"github.com/yamakiller/glacier-toolchain/logger"
	httppb "github.com/yamakiller/glacier-toolchain/pb/http"
	"net/http"
)

// Router 路由
type Router interface {
	//Use 添加中间件
	Use(m Middleware)

	//Auth 是否启用用户身份验证
	Auth(isEnable bool)

	//Permission 是否启用用户权限验证
	Permission(isEnable bool)

	//Allow 允许target标识
	Allow(targets ...fmt.Stringer)

	//AuditLog 是否开启审计日志
	AuditLog(isEnable bool)

	//RequiredNamespace 是否需要NameSpace
	RequiredNamespace(isEnable bool)

	//Handle 添加受认证保护的路由
	Handle(method, path string, h http.HandlerFunc) httppb.EntryDecorator

	//SetAuther 开始认证时 使用的认证器
	SetAuther(Auther)

	//SetAuditer 开始审计器, 记录用户操作
	SetAuditer(Auditer)

	//ServeHTTP 实现标准库路由
	ServeHTTP(http.ResponseWriter, *http.Request)

	//GetEndpoints 获取当前的路由条目信息
	GetEndpoints() *httppb.EntrySet

	// EnableAPIRoot 将服务路由表通过路径/暴露出去
	EnableAPIRoot()

	//SetLogger 设置路由的Logger, 用于Debug
	SetLogger(logger.Logger)

	// SetLabel 设置路由标签, 作用于Entry上
	SetLabel(...*httppb.Label)

	//SubRouter 子路由
	SubRouter(basePath string) SubRouter
}

// ResourceRouter 资源路由
type ResourceRouter interface {
	SubRouter
	// BasePath 设置资源路由的基础路径
	BasePath(path string)
}

// SubRouter 子路由或者分组路由
type SubRouter interface {
	//Auth 是否启用用户身份验证
	Auth(isEnable bool)

	//Permission 是否启用用户权限验证
	Permission(isEnable bool)

	//Allow 允许target标识
	Allow(targets ...fmt.Stringer)

	//AuditLog 是否开启审计日志
	AuditLog(isEnable bool)

	//RequiredNamespace 是否需要NameSpace
	RequiredNamespace(isEnable bool)

	//Use 添加中间件
	Use(m Middleware)

	//SetLabel SetLabel 设置路由标签, 作用于Entry上
	SetLabel(...*httppb.Label)

	//With 独立作用于某一个Handler
	With(m ...Middleware) SubRouter

	//Handle 添加受认证保护的路由
	Handle(method, path string, h http.HandlerFunc) httppb.EntryDecorator

	//ResourceRouter 资源路由器, 主要用于设置路由标签和资源名称,方便配置灵活的权限策略
	ResourceRouter(resourceName string, labels ...*httppb.Label) ResourceRouter
}
