package service

import (
	"fmt"

	"google.golang.org/grpc"
)

var (
	grpcServices = map[string]IGRPCService{}
)

// IGRPCService GRPC服务的实例
type IGRPCService interface {
	Registry(*grpc.Server)
	Config() error
	Name() string
}

// RegistryGrpcService 服务实例注册
func RegistryGrpcService(srv IGRPCService) {
	// 已经注册的服务禁止再次注册
	_, ok := grpcServices[srv.Name()]
	if ok {
		panic(fmt.Sprintf("grpc app %s has registed", srv.Name()))
	}

	grpcServices[srv.Name()] = srv
}

// LoadedGrpcService 查询加载成功的服务
func LoadedGrpcService() (svs []string) {
	for k := range grpcServices {
		svs = append(svs, k)
	}
	return
}

func GetGrpcService(name string) IGRPCService {
	srv, ok := grpcServices[name]
	if !ok {
		panic(fmt.Sprintf("grpc app %s not registed", name))
	}

	return srv
}

// LoadGrpcService 加载所有的Grpc app
func LoadGrpcService(server *grpc.Server) {
	for _, app := range grpcServices {
		app.Registry(server)
	}
}
