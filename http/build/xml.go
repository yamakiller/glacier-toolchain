package build

import (
	"bytes"
	"encoding/xml"
	"io"
	"net/http"
)

type xmlBind struct{}

func (xmlBind) Name() string {
	return "xml"
}

func (xmlBind) Bind(req *http.Request, obj interface{}) error {
	return decodeXML(req.Body, obj)
}

func (xmlBind) BindBody(body []byte, obj interface{}) error {
	return decodeXML(bytes.NewReader(body), obj)
}
func decodeXML(r io.Reader, obj interface{}) error {
	decoder := xml.NewDecoder(r)
	if err := decoder.Decode(obj); err != nil {
		return err
	}
	return validate(obj)
}
