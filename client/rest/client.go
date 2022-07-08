package rest

import (
	"github.com/yamakiller/glacier-toolchain/flowcontrol"
	"github.com/yamakiller/glacier-toolchain/logger"
	"net/http"
)

type RESTClient struct {
	flowLimiter flowcontrol.FlowLimiter
	client      *http.Client
	cookies     []*http.Cookie
	headers     http.Header
	log         logger.Logger
	baseURL     string

	authType AuthType
	user     *User
	token    string
}
