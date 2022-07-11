package client

import (
	kc "github.com/yamakiller/glacier-auth/client"
	"github.com/yamakiller/glacier-toolchain/logger"
	"github.com/yamakiller/glacier-toolchain/logger/zap"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"

	"{{.PKG}}/apps/example"
)

var (
	client *ClientSet
)

// SetGlobal 设置全局客户端
func SetGlobal(cli *ClientSet) {
	client = cli
}

// Instance Global 返回劝酒客户端对象
func Instance() *ClientSet {
	return client
}

// NewClient 根据配置信息实例化一个客户端
func NewClient(conf *kc.Config) (*ClientSet, error) {
	zap.DevelopmentSetup()
	log := zap.Instance()
	conn, err := grpc.Dial(
		conf.Address(),
		grpc.WithTransportCredentials(insecure.NewCredentials()),
		grpc.WithPerRPCCredentials(conf.Authentication),
	)
	if err != nil {
		return nil, err
	}

	return &ClientSet{
		conn: conn,
		log:  log,
	}, nil
}

// Client 客户端
type ClientSet struct {
	conn *grpc.ClientConn
	log  logger.Logger
}

// Book服务的SDK
func (c *ClientSet) Example() example.ServiceClient {
	return example.NewServiceClient(c.conn)
}