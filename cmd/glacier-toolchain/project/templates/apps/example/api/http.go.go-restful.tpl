package api

import (
	restfulspec "github.com/emicklei/go-restful-openapi"
	"github.com/emicklei/go-restful/v3"
	toolchain-service "github.com/yamakiller/glacier-toolchain/service"
	"github.com/yamakiller/glacier-toolchain/http/response"
	"github.com/yamakiller/glacier-toolchain/logger"
	"github.com/yamakiller/glacier-toolchain/logger/zap"

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

func (h *handler) Registry(ws *restful.WebService) {
	tags := []string{"{{.AppName}}s"}

	ws.Route(ws.POST("").To(h.Create{{.CapName}}).
		Doc("create a {{.AppName}}").
		Metadata(restfulspec.KeyOpenAPITags, tags).
		Reads({{.AppName}}.Create{{.CapName}}Request{}).
		Writes(response.NewData({{.AppName}}.{{.CapName}}{})))

	ws.Route(ws.GET("/").To(h.Query{{.CapName}}).
		Doc("get all {{.AppName}}s").
		Metadata(restfulspec.KeyOpenAPITags, tags).
		Metadata("action", "list").
		Reads({{.AppName}}.Create{{.CapName}}Request{}).
		Writes(response.NewData({{.AppName}}.{{.CapName}}Set{})).
		Returns(200, "OK", {{.AppName}}.{{.CapName}}Set{}))

	ws.Route(ws.GET("/{id}").To(h.Describe{{.CapName}}).
		Doc("get a {{.AppName}}").
		Param(ws.PathParameter("id", "identifier of the {{.AppName}}").DataType("integer").DefaultValue("1")).
		Metadata(restfulspec.KeyOpenAPITags, tags).
		Writes(response.NewData({{.AppName}}.{{.CapName}}{})).
		Returns(200, "OK", response.NewData({{.AppName}}.{{.CapName}}{})).
		Returns(404, "Not Found", nil))

	ws.Route(ws.PUT("/{id}").To(h.Update{{.CapName}}).
		Doc("update a {{.AppName}}").
		Param(ws.PathParameter("id", "identifier of the {{.AppName}}").DataType("string")).
		Metadata(restfulspec.KeyOpenAPITags, tags).
		Reads({{.AppName}}.Create{{.CapName}}Request{}))

	ws.Route(ws.PATCH("/{id}").To(h.Patch{{.CapName}}).
		Doc("patch a {{.AppName}}").
		Param(ws.PathParameter("id", "identifier of the {{.AppName}}").DataType("string")).
		Metadata(restfulspec.KeyOpenAPITags, tags).
		Reads({{.AppName}}.Create{{.CapName}}Request{}))

	ws.Route(ws.DELETE("/{id}").To(h.Delete{{.CapName}}).
		Doc("delete a {{.AppName}}").
		Metadata(restfulspec.KeyOpenAPITags, tags).
		Param(ws.PathParameter("id", "identifier of the {{.AppName}}").DataType("string")))
}

func init() {
	toolchain-service.RegistryRESTfulService(h)
}