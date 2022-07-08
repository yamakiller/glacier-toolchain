package generater

import (
	"github.com/golang/protobuf/protoc-gen-go/descriptor"
	"github.com/yamakiller/glacier-toolchain/pb/http"
	"google.golang.org/protobuf/proto"
)

func GetServiceMethodRestAPIOption(m *descriptor.MethodDescriptorProto) *http.Entry {
	if m.Options != nil && proto.HasExtension(m.Options, http.E_RestApi) {
		ext := proto.GetExtension(m.Options, http.E_RestApi)
		if ext != nil {
			if x, _ := ext.(*http.Entry); x != nil {
				return x
			}
		}
	}
	return nil
}
