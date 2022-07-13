package {{.AppName}}

import (
	"net/http"
	"time"

	"github.com/go-playground/validator/v10"
	"github.com/imdario/mergo"
	"github.com/yamakiller/glacier-toolchain/http/request"
	pb_request "github.com/yamakiller/glacier-toolchain/pb/request"
	"github.com/rs/xid"
)

const (
	AppName = "{{.AppName}}"
)

var (
	validate = validator.New()
)

//TODO: 插入外部暴露接口代码