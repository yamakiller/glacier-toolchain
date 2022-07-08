package simulate

import (
	"github.com/yamakiller/glacier-toolchain/exception"
	"github.com/yamakiller/glacier-toolchain/http/router"
	httppb "github.com/yamakiller/glacier-toolchain/pb/http"
	"net/http"
	"strings"
)

var (
	// SimulateTestToken 用于内部模拟测试
	SimulateTestToken = "dfdfdfdffdfdfdf"
)

// NewSimulateAuther 实例一个模拟鉴权
func NewSimulateAuther() router.Auther {
	return &simulateAuther{}
}

type simulateAuther struct{}

func (m *simulateAuther) Auth(r *http.Request, entry httppb.Entry) (authInfo interface{}, err error) {
	authHeader := r.Header.Get("Authorization")
	if authHeader == "" {
		return nil, exception.NewUnauthorized("Authorization missed in header")
	}

	headerSlice := strings.Split(authHeader, " ")
	if len(headerSlice) != 2 {
		return nil, exception.NewUnauthorized("Authorization header value is not validated, must be: {token_type} {token}")
	}

	access := headerSlice[1]

	if access != SimulateTestToken {
		return nil, exception.NewUnauthorized("permission deny")
	}
	return access, nil
}

func (m *simulateAuther) ResponseHook(http.ResponseWriter, *http.Request, httppb.Entry) {

}
