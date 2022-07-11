package api

import (
	restfulspec "github.com/emicklei/go-restful-openapi"
	"github.com/emicklei/go-restful/v3"
	toolchain-service "github.com/yamakiller/glacier-toolchain/service"
	"github.com/yamakiller/glacier-toolchain/http/response"
	"github.com/yamakiller/glacier-toolchain/logger"
	"github.com/yamakiller/glacier-toolchain/logger/zap"

	"{{.PKG}}/apps/example"
)

var (
	h = &handler{}
)

type handler struct {
	service example.ServiceServer
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

func (h *handler) Registry(ws *restful.WebService) {
	tags := []string{"examples"}

	ws.Route(ws.POST("").To(h.CreateExample).
		Doc("create a example").
		Metadata(restfulspec.KeyOpenAPITags, tags).
		Reads(example.CreateExampleRequest{}).
		Writes(response.NewData(example.Example{})))

	ws.Route(ws.GET("/").To(h.QueryExample).
		Doc("get all examples").
		Metadata(restfulspec.KeyOpenAPITags, tags).
		Metadata("action", "list").
		Reads(example.CreateExampleRequest{}).
		Writes(response.NewData(example.ExampleSet{})).
		Returns(200, "OK", example.ExampleSet{}))

	ws.Route(ws.GET("/{id}").To(h.DescribeExample).
		Doc("get a example").
		Param(ws.PathParameter("id", "identifier of the example").DataType("integer").DefaultValue("1")).
		Metadata(restfulspec.KeyOpenAPITags, tags).
		Writes(response.NewData(example.Example{})).
		Returns(200, "OK", response.NewData(example.Example{})).
		Returns(404, "Not Found", nil))

	ws.Route(ws.PUT("/{id}").To(h.UpdateExample).
		Doc("update a example").
		Param(ws.PathParameter("id", "identifier of the example").DataType("string")).
		Metadata(restfulspec.KeyOpenAPITags, tags).
		Reads(example.CreateExampleRequest{}))

	ws.Route(ws.PATCH("/{id}").To(h.PatchExample).
		Doc("patch a example").
		Param(ws.PathParameter("id", "identifier of the example").DataType("string")).
		Metadata(restfulspec.KeyOpenAPITags, tags).
		Reads(example.CreateExampleRequest{}))

	ws.Route(ws.DELETE("/{id}").To(h.DeleteExample).
		Doc("delete a example").
		Metadata(restfulspec.KeyOpenAPITags, tags).
		Param(ws.PathParameter("id", "identifier of the example").DataType("string")))
}

func init() {
	toolchain-service.RegistryRESTfulService(h)
}