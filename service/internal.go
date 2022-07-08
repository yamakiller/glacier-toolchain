package service

import "fmt"

var (
	internalServices = map[string]IInternalService{}
)

// IInternalService 内部服务实例, 不需要暴露
type IInternalService interface {
	Config() error
	Name() string
}

// RegistryInternalService 服务实例注册
func RegistryInternalService(srv IInternalService) {
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

func GetInternalService(name string) IInternalService {
	srv, ok := internalServices[name]
	if !ok {
		panic(fmt.Sprintf("internal app %s not registed", name))
	}

	return srv
}
