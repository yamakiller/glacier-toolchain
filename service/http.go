package service

import (
	"fmt"
	"github.com/yamakiller/glacier-toolchain/http/router"
	"strings"
)

var (
	httpServices = map[string]HTTPService{}
)

// HTTPService Http服务的实例
type HTTPService interface {
	Registry(router.SubRouter)
	Config() error
	Name() string
}

// RegistryHttpApp 服务实例注册
func RegistryHttpApp(srv HTTPService) {
	// 已经注册的服务禁止再次注册
	_, ok := httpServices[srv.Name()]
	if ok {
		panic(fmt.Sprintf("http app %s has registed", srv.Name()))
	}

	httpServices[srv.Name()] = srv
}

// LoadedHttpService 查询加载成功的服务
func LoadedHttpService() (svs []string) {
	for k := range httpServices {
		svs = append(svs, k)
	}
	return
}

func GetHttpService(name string) HTTPService {
	app, ok := httpServices[name]
	if !ok {
		panic(fmt.Sprintf("http app %s not registed", name))
	}

	return app
}

// LoadHttpService 装载所有的http service
func LoadHttpService(pathPrefix string, root router.Router) {
	for _, api := range httpServices {
		if pathPrefix != "" && !strings.HasPrefix(pathPrefix, "/") {
			pathPrefix = "/" + pathPrefix
		}
		api.Registry(root.SubRouter(pathPrefix))
	}
}
