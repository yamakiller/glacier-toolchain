package response

import (
	"encoding/json"
	"errors"
	"github.com/yamakiller/glacier-toolchain/exception"
	"io"
	"io/ioutil"
)

// GetDataFromBody 获取body中的数据
func GetDataFromBody(body io.ReadCloser, v interface{}) error {
	defer func(body io.ReadCloser) {
		err := body.Close()
		if err != nil {

		}
	}(body)

	bytesB, err := ioutil.ReadAll(body)
	if err != nil {
		return err
	}
	data := NewData(v)

	if err := json.Unmarshal(bytesB, data); err != nil {
		return err
	}

	if data.Code == nil {
		return errors.New("response code is nil")
	}

	if *data.Code != 0 {
		return exception.NewAPIException(data.Namespace, *data.Code, data.Reason, data.Message)
	}

	return nil
}
