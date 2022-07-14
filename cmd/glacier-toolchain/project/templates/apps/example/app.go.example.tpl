package example

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
	AppName = "example"
)

var (
	validate = validator.New()
)

func NewCreateExampleRequest() *CreateExampleRequest {
	return &CreateExampleRequest{}
}

func NewBook(req *CreateExampleRequest) (*Book, error) {
	if err := req.Validate(); err != nil {
		return nil, err
	}

	return &Example{
		Id:       xid.New().String(),
		CreateAt: time.Now().UnixMicro(),
		Data:     req,
	}, nil
}

func (req *CreateExampleRequest) Validate() error {
	return validate.Struct(req)
}

func NewExampleSet() *BookSet {
	return &ExampleSet{
		Items: []*Example{},
	}
}

func (s *ExampleSet) Add(item *Example) {
	s.Items = append(s.Items, item)
}

func NewDefaultExample() *Example {
	return &Example{
		Data: &CreateExampleRequest{},
	}
}

func (i *Example) Update(req *UpdateExampleRequest) {
	i.UpdateAt = time.Now().UnixMicro()
	i.UpdateBy = req.UpdateBy
	i.Data = req.Data
}

func (i *Example) Patch(req *UpdateExampleRequest) error {
	i.UpdateAt = time.Now().UnixMicro()
	i.UpdateBy = req.UpdateBy
	return mergo.MergeWithOverwrite(i.Data, req.Data)
}

func NewDescribeExampleRequest(id string) *DescribeExampleRequest {
	return &DescribeExampleRequest{
		Id: id,
	}
}

func NewQueryExampleRequest() *QueryExampleRequest {
	return &QueryExampleRequest{
		Page: request.NewDefaultPageRequest(),
	}
}

func NewQueryExampleRequestFromHTTP(r *http.Request) *QueryExampleRequest {
	qs := r.URL.Query()
	return &QueryExampleRequest{
		Page:     request.NewPageRequestFromHTTP(r),
		Keywords: qs.Get("keywords"),
	}
}

func NewPutExampleRequest(id string) *UpdateExampleRequest {
	return &UpdateExampleRequest{
		Id:         id,
		UpdateMode: pb_request.UpdateMode_PUT,
		UpdateAt:   time.Now().UnixMicro(),
		Data:       NewCreateExampleRequest(),
	}
}

func NewPatchExampleRequest(id string) *UpdateExampleRequest {
	return &UpdateExampleRequest{
		Id:         id,
		UpdateMode: pb_request.UpdateMode_PATCH,
		UpdateAt:   time.Now().UnixMicro(),
		Data:       NewCreateExampleRequest(),
	}
}

func NewDeleteExampleRequestWithID(id string) *DeleteExampleRequest {
	return &DeleteExampleRequest{
		Id: id,
	}
}