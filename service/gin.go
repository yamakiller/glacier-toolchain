package service

import (
	"fmt"
	"github.com/gin-gonic/gin"
	"path"
	"strings"
)

var (
	ginServices = map[string]GinService{}
)

//GinService HTTPService Http服务的实例
type GinService interface {
	Registry(gin.IRouter)
	Config() error
	Name() string
	Version() string
}

// RegistryGinService 服务实例注册
func RegistryGinService(srv GinService) {
	// 已经注册的服务禁止再次注册
	_, ok := ginServices[srv.Name()]
	if ok {
		panic(fmt.Sprintf("gin app %s has registed", srv.Name()))
	}

	ginServices[srv.Name()] = srv
}

// LoadedGinService 查询加载成功的服务
func LoadedGinService() (svs []string) {
	for k := range ginServices {
		svs = append(svs, k)
	}
	return
}

func GetGinService(name string) GinService {
	serv, ok := ginServices[name]
	if !ok {
		panic(fmt.Sprintf("http app %s not registed", name))
	}

	return serv
}

// LoadGinService 装载所有的gin service
func LoadGinService(pathPrefix string, root gin.IRouter) {
	for _, api := range ginServices {
		if pathPrefix != "" && !strings.HasPrefix(pathPrefix, "/") {
			pathPrefix = "/" + pathPrefix
		}
		api.Registry(root.Group(path.Join(pathPrefix, api.Version(), api.Name())))
	}
}
