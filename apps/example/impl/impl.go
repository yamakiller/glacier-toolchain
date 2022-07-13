package impl

import (


"go.mongodb.org/mongo-driver/mongo"
	toolchain-service "github.com/yamakiller/glacier-toolchain/service"
	"github.com/yamakiller/glacier-toolchain/logger"
	"github.com/yamakiller/glacier-toolchain/logger/zap"
	"google.golang.org/grpc"

	"github.com/yamakiller/glacier-toolchain/apps/example"
	"github.com/yamakiller/glacier-toolchain/conf"
)

var (
	// Service 服务实例
	svr = &service{}
)

type service struct {


col *mongo.Collection
	log  logger.Logger
	example.UnimplementedServiceServer
}

func (s *service) Config() error {


db, err := conf.Instance().Mongo.GetDB()
	if err != nil {
		return err
	}
	s.col = db.Collection(s.Name())

	s.log = zap.Instance().Named(s.Name())
	return nil
}

func (s *service) Name() string {
	return example.AppName
}

func (s *service) Registry(server *grpc.Server) {
	example.RegisterServiceServer(server, svr)
}

func init() {
	toolchain-service.RegistryGrpcService(svr)
}