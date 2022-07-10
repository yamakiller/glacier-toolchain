    package api

    import (
    	"github.com/gin-gonic/gin"
    	"github.com/yamakiller/glacier-toolchain/logger"
    	"github.com/yamakiller/glacier-toolchain/logger/zap"
    	toolchain-service "github.com/yamakiller/glacier-toolchain/service"

    	"{{.PKG}}/apps/example"
    )

    var (
    	h = &handler{}
    )

    type handler struct {
    	service book.ServiceServer
    	log     logger.Logger
    }

    func (h *handler) Config() error {
    	h.log = zap.Instance().Named(example.AppName)
    	h.service = toolchain-service.GetGrpcService(example.AppName).(example.ServiceServer)
    	return nil
    }

    func (h *handler) Name() string {
    	return example.AppName
    }

    func (h *handler) Version() string {
    	return "v1"
    }

    func (h *handler) Registry(r gin.IRouter) {
    	r.POST("/", h.CreateExample)
    	r.GET("/", h.QueryExample)
    	r.GET("/:id", h.DescribeExample)
    	r.PUT("/:id", h.PutExample)
    	r.PATCH("/:id", h.PatchExample)
    	r.DELETE("/:id", h.DeleteExample)
    }

    func init() {
    	toolchain-service.RegistryGinService(h)