package protocol

import (
	"net"

	"google.golang.org/grpc"
{{ if $.EnableGlacierAuth -}}
	"github.com/yamakiller/glacier-auth/client/interceptor"
{{- end }}
	"github.com/yamakiller/glacier-toolchain/service"
	"github.com/yamakiller/glacier-toolchain/grpc/middleware/recovery"
	"github.com/yamakiller/glacier-toolchain/logger"
	"github.com/yamakiller/glacier-toolchain/logger/zap"

	"{{.PKG}}/conf"
)

// NewGRPCService todo
func NewGRPCService() *GRPCService {
	log := zap.Instance().Named("GRPC Service")
{{ if $.EnableGlacierAuth -}}
	c, err := conf.Instance().GlacierAuth.Client()
	if err != nil {
	    panic(err)
	}
{{- end }}

	rc := recovery.NewInterceptor(recovery.NewZapRecoveryHandler())
	grpcServer := grpc.NewServer(grpc.ChainUnaryInterceptor(
		rc.UnaryServerInterceptor(),
{{ if $.EnableGlacierAuth -}}
		interceptor.GrpcAuthUnaryServerInterceptor(c),
{{- end }}
	))

	return &GRPCService{
		svr: grpcServer,
		l:   log,
		c:   conf.Instance(),
	}
}

// GRPCService grpc服务
type GRPCService struct {
	svr *grpc.Server
	l   logger.Logger
	c   *conf.Config
}

// Start 启动GRPC服务
func (s *GRPCService) Start() {
	// 装载所有GRPC服务
	service.LoadGrpcService(s.svr)
	// 启动HTTP服务
	lis, err := net.Listen("tcp", s.c.App.GRPC.Addr())
	if err != nil {
		s.l.Errorf("listen grpc tcp conn error, %s", err)
		return
	}

	s.l.Infof("GRPC 服务监听地址: %s", s.c.App.GRPC.Addr())
	if err := s.svr.Serve(lis); err != nil {
		if err == grpc.ErrServerStopped {
			s.l.Info("service is stopped")
		}

		s.l.Error("start grpc service error, %s", err.Error())
		return
	}
}

// Stop 启动GRPC服务
func (s *GRPCService) Stop() error {
	s.svr.GracefulStop()
	return nil
}