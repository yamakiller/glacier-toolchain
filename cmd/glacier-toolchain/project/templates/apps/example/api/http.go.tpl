package api

import (
	"github.com/yamakiller/glacier-toolchain/http/label"
	"github.com/yamakiller/glacier-toolchain/http/router"
	"github.com/yamakiller/glacier-toolchain/logger"
	"github.com/yamakiller/glacier-toolchain/logger/zap"

	"{{.PKG}}/apps/example"
	toolchain-service "github.com/yamakiller/glacier-toolchain/service"
)

var (
	h = &handler{}
)

type handler struct {
	service book.ServiceServer
	log     logger.Logger
}

func (h *handler) Config() error {
	h.log = zap.L().Named(example.AppName)
	h.service = toolchain-service.GetGrpcService(example.AppName).(example.ServiceServer)
	return nil
}

func (h *handler) Name() string {
	return example.AppName
}

func (h *handler) Registry(r router.SubRouter) {
	rr := r.ResourceRouter("examples")
	rr.BasePath("examples")
	rr.Handle("POST", "/", h.CreateExample).AddLabel(label.Create)
	rr.Handle("GET", "/", h.QueryExample).AddLabel(label.List)
	rr.Handle("GET", "/:id", h.DescribeExample).AddLabel(label.Get)
	rr.Handle("PUT", "/:id", h.PutExample).AddLabel(label.Update)
	rr.Handle("PATCH", "/:id", h.PatchExample).AddLabel(label.Update)
	rr.Handle("DELETE", "/:id", h.DeleteExample).AddLabel(label.Delete)
}

func init() {
	toolchain-service.RegistryHttpService(h)
}