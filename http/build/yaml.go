package build

import (
	"bytes"
	"gopkg.in/yaml.v3"
	"io"
	"net/http"
)

type yamlBind struct{}

func (yamlBind) Name() string {
	return "yaml"
}

func (yamlBind) Bind(req *http.Request, obj interface{}) error {
	return decodeYAML(req.Body, obj)
}

func (yamlBind) BindBody(body []byte, obj interface{}) error {
	return decodeYAML(bytes.NewReader(body), obj)
}

func decodeYAML(r io.Reader, obj interface{}) error {
	decoder := yaml.NewDecoder(r)
	if err := decoder.Decode(obj); err != nil {
		return err
	}
	return validate(obj)
}
