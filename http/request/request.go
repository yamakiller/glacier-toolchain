package request

import (
	"encoding/json"
	"fmt"
	"github.com/yamakiller/glacier-toolchain/exception"
	"io"
	"io/ioutil"
	"net/http"
)

var (
	// BodyMaxContentLength body最大大小 默认64M
	BodyMaxContentLength int64 = 1 << 26
)

// ReadBody 读取Body当中的数据
func ReadBody(r *http.Request) ([]byte, error) {
	// 检测请求大小
	if r.ContentLength == 0 {
		return nil, exception.NewBadRequest("request body is empty")
	}
	if r.ContentLength > BodyMaxContentLength {
		return nil, exception.NewBadRequest(
			"the body exceeding the maximum limit, max size %dM",
			BodyMaxContentLength/1024/1024)
	}

	// 读取body数据
	body, err := ioutil.ReadAll(r.Body)
	defer func(Body io.ReadCloser) {
		err := Body.Close()
		if err != nil {

		}
	}(r.Body)

	if err != nil {
		return nil, exception.NewBadRequest(
			fmt.Sprintf("read request body error, %s", err))
	}

	return body, nil
}

// GetDataFromRequest todo
func GetDataFromRequest(r *http.Request, v interface{}) error {
	body, err := ReadBody(r)
	if err != nil {
		return err
	}

	return json.Unmarshal(body, v)
}
