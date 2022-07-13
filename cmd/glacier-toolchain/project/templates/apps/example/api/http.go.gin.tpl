    package api

    import (
    	"github.com/gin-gonic/gin"
    	"github.com/yamakiller/glacier-toolchain/logger"
    	"github.com/yamakiller/glacier-toolchain/logger/zap"
    	toolchain-service "github.com/yamakiller/glacier-toolchain/service"

    	"{{.PKG}}/apps/{{.AppName}}"
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

    func (h *handler) Version() string {
    	return "v1"
    }

    func (h *handler) Registry(r gin.IRouter) {
    	r.POST("/", h.Create{{.CapName}})
    	r.GET("/", h.Query{{.CapName}})
    	r.GET("/:id", h.Describe{{.CapName}})
    	r.PUT("/:id", h.Put{{.CapName}})
    	r.PATCH("/:id", h.Patch{{.CapName}})
    	r.DELETE("/:id", h.Delete{{.CapName}})
    }

    func init() {
    	toolchain-service.RegistryGinService(h)
    }