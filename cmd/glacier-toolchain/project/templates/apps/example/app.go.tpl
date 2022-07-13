package {{.AppName}}

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
	AppName = "{{.AppName}}"
)

var (
	validate = validator.New()
)

/*Ê¾Àý´úÂë
func NewCreate{{.CapName}}Request() *Create{{.CapName}}Request {
	return &Create{{.CapName}}Request{}
}

func New{{.CapName}}(req *Create{{.CapName}}Request) (*Book, error) {
	if err := req.Validate(); err != nil {
		return nil, err
	}

	return &{{.CapName}}{
		Id:       xid.New().String(),
		CreateAt: time.Now().UnixMicro(),
		Data:     req,
	}, nil
}

func (req *Create{{.CapName}}Request) Validate() error {
	return validate.Struct(req)
}

func New{{.CapName}}Set() *BookSet {
	return &{{.CapName}}Set{
		Items: []*{{.CapName}}{},
	}
}

func (s *{{.CapName}}Set) Add(item *{{.CapName}}) {
	s.Items = append(s.Items, item)
}

func NewDefault{{.CapName}}() *{{.CapName}} {
	return &{{.CapName}}{
		Data: &Create{{.CapName}}Request{},
	}
}

func (i *{{.CapName}}) Update(req *Update{{.CapName}}Request) {
	i.UpdateAt = time.Now().UnixMicro()
	i.UpdateBy = req.UpdateBy
	i.Data = req.Data
}

func (i *{{.CapName}}) Patch(req *Update{{.CapName}}Request) error {
	i.UpdateAt = time.Now().UnixMicro()
	i.UpdateBy = req.UpdateBy
	return mergo.MergeWithOverwrite(i.Data, req.Data)
}

func NewDescribe{{.CapName}}Request(id string) *Describe{{.CapName}}Request {
	return &Describe{{.CapName}}Request{
		Id: id,
	}
}

func NewQuery{{.CapName}}Request() *Query{{.CapName}}Request {
	return &Query{{.CapName}}Request{
		Page: request.NewDefaultPageRequest(),
	}
}

func NewQuery{{.CapName}}RequestFromHTTP(r *http.Request) *Query{{.CapName}}Request {
	qs := r.URL.Query()
	return &Query{{.CapName}}Request{
		Page:     request.NewPageRequestFromHTTP(r),
		Keywords: qs.Get("keywords"),
	}
}

func NewPut{{.CapName}}Request(id string) *Update{{.CapName}}Request {
	return &Update{{.CapName}}Request{
		Id:         id,
		UpdateMode: pb_request.UpdateMode_PUT,
		UpdateAt:   time.Now().UnixMicro(),
		Data:       NewCreate{{.CapName}}Request(),
	}
}

func NewPatch{{.CapName}}Request(id string) *Update{{.CapName}}Request {
	return &Update{{.CapName}}Request{
		Id:         id,
		UpdateMode: pb_request.UpdateMode_PATCH,
		UpdateAt:   time.Now().UnixMicro(),
		Data:       NewCreate{{.CapName}}Request(),
	}
}

func NewDelete{{.CapName}}RequestWithID(id string) *Delete{{.CapName}}Request {
	return &Delete{{.CapName}}Request{
		Id: id,
	}
}*/