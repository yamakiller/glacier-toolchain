package service

import "fmt"

var (
	internalServices = map[string]InternalService{}
)

// InternalService 内部服务实例, 不需要暴露
type InternalService interface {
	Config() error
	Name() string
}

// RegistryInternalService 服务实例注册
func RegistryInternalService(srv InternalService) {
	// 已经注册的服务禁止再次注册
	_, ok := internalServices[srv.Name()]
	if ok {
		panic(fmt.Sprintf("internal app %s has registed", srv.Name()))
	}

	internalServices[srv.Name()] = srv
}

// LoadedInternalService 查询加载成功的服务
func LoadedInternalService() (svs []string) {
	for k := range internalServices {
		svs = append(svs, k)
	}
	return
}

func GetInternalService(name string) InternalService {
	app, ok := internalServices[name]
	if !ok {
		panic(fmt.Sprintf("internal app %s not registed", name))
	}

	return app
}
