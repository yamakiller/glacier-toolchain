package impl

import (
{{ if $.EnableMySQL -}}
    "gorm.io/gorm"
{{- end }}
{{ if $.EnablePostgreSQL -}}
     "gorm.io/gorm"
{{- end }}
{{ if $.EnableMongoDB -}}
	"go.mongodb.org/mongo-driver/mongo"
{{- end }}


	toolchain-service "github.com/yamakiller/glacier-toolchain/service"
	"github.com/yamakiller/glacier-toolchain/logger"
	"github.com/yamakiller/glacier-toolchain/logger/zap"
	"google.golang.org/grpc"

	"{{.PKG}}/apps/{{.AppName}}"
	"{{.PKG}}/conf"
)

var (
	// Service 服务实例
	svr = &service{}
)

type service struct {
{{ if $.EnableMySQL -}}
	db   *gorm.DB
{{- end }}
{{ if $.EnablePostgreSQL -}}
    db *gorm.DB
{{- end }}
{{ if $.EnableMongoDB -}}
	col *mongo.Collection
{{- end }}
	log  logger.Logger
	{{.AppName}}.UnimplementedServiceServer
}

func (s *service) Config() error {
{{ if $.EnableMySQL -}}
	db, err := conf.Instance().MySQL.GetDB()
	if err != nil {
		return err
	}
	s.db = db
{{- end }}
{{ if $.EnablePostgreSQL -}}
    db, err := conf.Instance().PostgreSQL.GetDB()
    	if err != nil {
    		return err
    	}
    	s.db = db
{{- end }}
{{ if $.EnableMongoDB -}}
	db, err := conf.Instance().Mongo.GetDB()
	if err != nil {
		return err
	}
	s.col = db.Collection(s.Name())
{{- end }}

	s.log = zap.Instance().Named(s.Name())
	return nil
}

func (s *service) Name() string {
	return {{.AppName}}.AppName
}

func (s *service) Registry(server *grpc.Server) {
	{{.AppName}}.RegisterServiceServer(server, svr)
}

func init() {
	toolchain-service.RegistryGrpcService(svr)
}