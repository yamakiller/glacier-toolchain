package service

import (
	"fmt"
	"strings"

	"github.com/emicklei/go-restful/v3"
)

var (
	restfulServices = map[string]RESTfulService{}
)

// RESTfulService Http服务的实例
type RESTfulService interface {
	Registry(*restful.WebService)
	Config() error
	Name() string
	Version() string
}

// RegistryRESTfulService 服务实例注册
func RegistryRESTfulService(app RESTfulService) {
	// 已经注册的服务禁止再次注册
	_, ok := restfulServices[app.Name()]
	if ok {
		panic(fmt.Sprintf("http app %s has registed", app.Name()))
	}

	restfulServices[app.Name()] = app
}

// LoadedRESTfulService 查询加载成功的服务
func LoadedRESTfulService() (svs []string) {
	for k := range restfulServices {
		svs = append(svs, k)
	}
	return
}

func GetRESTfulService(name string) RESTfulService {
	app, ok := restfulServices[name]
	if !ok {
		panic(fmt.Sprintf("http app %s not registed", name))
	}

	return app
}

// LoadRESTfulService 装载所有的http service
func LoadRESTfulService(pathPrefix string, root *restful.Container) {
	for _, api := range restfulServices {
		pathPrefix = strings.TrimSuffix(pathPrefix, "/")
		ws := new(restful.WebService)
		ws.
			Path(fmt.Sprintf("%s/%s/%s", pathPrefix, api.Version(), api.Name())).
			Consumes(restful.MIME_JSON, restful.MIME_XML).
			Produces(restful.MIME_JSON, restful.MIME_XML)

		api.Registry(ws)
		root.Add(ws)
	}
}
