package api

import (
	"github.com/yamakiller/glacier-toolchain/http/label"
	"github.com/yamakiller/glacier-toolchain/http/router"
	"github.com/yamakiller/glacier-toolchain/logger"
	"github.com/yamakiller/glacier-toolchain/logger/zap"

	"{{.PKG}}/apps/{{.AppName}}"
	toolchain-service "github.com/yamakiller/glacier-toolchain/service"
)

var (
	h = &handler{}
)

type handler struct {
	service {{.AppName}}.ServiceServer
	log     logger.Logger
}

func (h *handler) Config() error {
	h.log = zap.Instance().Named({{.AppName}}.AppName)
	h.service = toolchain-service.GetGrpcService({{.AppName}}.AppName).({{.AppName}}.ServiceServer)
	return nil
}

func (h *handler) Name() string {
	return {{.AppName}}.AppName
}

func (h *handler) Registry(r router.SubRouter) {
	rr := r.ResourceRouter("{{.AppName}}s")
	rr.BasePath("{{.AppName}}s")
	//TODO: 注册HTTP外部接口
    /* 示例
	rr.Handle("POST", "/", h.Create{{.CapName}}).AddLabel(label.Create)
	rr.Handle("GET", "/", h.Query{{.CapName}}).AddLabel(label.List)
	rr.Handle("GET", "/:id", h.Describe{{.CapName}}).AddLabel(label.Get)
	rr.Handle("PUT", "/:id", h.Put{{.CapName}}).AddLabel(label.Update)
	rr.Handle("PATCH", "/:id", h.Patch{{.CapName}}).AddLabel(label.Update)
	rr.Handle("DELETE", "/:id", h.Delete{{.CapName}}).AddLabel(label.Delete)
	*/
}

func init() {
	toolchain-service.RegistryHttpService(h)
}