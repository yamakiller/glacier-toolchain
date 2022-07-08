package gcontext

import (
	"github.com/yamakiller/glacier-toolchain/exception"
	"google.golang.org/grpc/metadata"
	"strconv"
)

var (
	// Namespace todo
	Namespace = "default"
)

const (
	// ResponseCodeHeader 回复头 x-rpc-code
	ResponseCodeHeader = "x-rpc-code"
	// ResponseReasonHeader 回复头 x-rpc-reason
	ResponseReasonHeader = "x-rpc-reason"
	// ResponseDescHeader 回复头 x-rpc-desc
	ResponseDescHeader = "x-rpc-desc"
	// ResponseMetaHeader 回复头 x-rpc-meta
	ResponseMetaHeader = "x-rpc-meta"
	// ResponseDataHeader 回复头 x-rpc-data
	ResponseDataHeader = "x-rpc-data"
)

// NewExceptionFromTrailer 实例化一个API异常
func NewExceptionFromTrailer(md metadata.MD, err error) exception.IAPIException {
	ctx := newGrpcCtx(md)
	code, _ := strconv.Atoi(ctx.get(ResponseCodeHeader))
	reason := ctx.get(ResponseReasonHeader)
	message := ctx.get(ResponseDescHeader)
	ctx.get(ResponseMetaHeader)
	ctx.get(ResponseDataHeader)
	if message == "" {
		message = err.Error()
	}
	return exception.NewAPIException(Namespace, code, reason, message)
}
