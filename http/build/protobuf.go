package build

import (
	"errors"
	"google.golang.org/protobuf/proto"
	"io/ioutil"
	"net/http"
)

type protobufBind struct{}

func (protobufBind) Name() string {
	return "protobuf"
}

func (b protobufBind) Bind(req *http.Request, obj interface{}) error {
	buf, err := ioutil.ReadAll(req.Body)
	if err != nil {
		return err
	}
	return b.BindBody(buf, obj)
}

func (protobufBind) BindBody(body []byte, obj interface{}) error {
	msg, ok := obj.(proto.Message)
	if !ok {
		return errors.New("obj is not ProtoMessage")
	}
	if err := proto.Unmarshal(body, msg); err != nil {
		return err
	}
	// Here it's same to return validate(obj), but util now we can't add
	// `binding:""` to the struct which automatically generate by gen-proto
	return nil
}
