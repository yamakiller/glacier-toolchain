package api

import (
	"net/http"

	"github.com/yamakiller/glacier-toolchain/http/context"
	"github.com/yamakiller/glacier-toolchain/http/request"
	"github.com/yamakiller/glacier-toolchain/http/response"

	"{{.PKG}}/apps/example"
)

func (h *handler) CreateExample(w http.ResponseWriter, r *http.Request) {
	req := example.NewCreateExampleRequest()
	if err := request.GetDataFromRequest(r, req); err != nil {
		response.Failed(w, err)
		return
	}

	set, err := h.service.CreateExample(r.Context(), req)
	if err != nil {
		response.Failed(w, err)
		return
	}
	response.Success(w, set)
}

func (h *handler) QueryExample(w http.ResponseWriter, r *http.Request) {
	req := example.NewQueryExampleRequestFromHTTP(r)
	set, err := h.service.QueryExample(r.Context(), req)
	if err != nil {
		response.Failed(w, err)
		return
	}
	response.Success(w, set)
}

func (h *handler) DescribeExample(w http.ResponseWriter, r *http.Request) {
	ctx := context.GetContext(r)
	req := example.NewDescribeExampleRequest(ctx.PS.ByName("id"))
	ins, err := h.service.DescribeExample(r.Context(), req)
	if err != nil {
		response.Failed(w, err)
		return
	}

	response.Success(w, ins)
}

func (h *handler) PutExample(w http.ResponseWriter, r *http.Request) {
	ctx := context.GetContext(r)
	req := example.NewPutExampleRequest(ctx.PS.ByName("id"))
	if err := request.GetDataFromRequest(r, req.Data); err != nil {
		response.Failed(w, err)
		return
	}

	set, err := h.service.UpdateExample(r.Context(), req)
	if err != nil {
		response.Failed(w, err)
		return
	}
	response.Success(w, set)
}

func (h *handler) PatchExample(w http.ResponseWriter, r *http.Request) {
	ctx := context.GetContext(r)
	req := example.NewPatchExampleRequest(ctx.PS.ByName("id"))
	if err := request.GetDataFromRequest(r, req.Data); err != nil {
		response.Failed(w, err)
		return
	}

	set, err := h.service.UpdateExample(r.Context(), req)
	if err != nil {
		response.Failed(w, err)
		return
	}
	response.Success(w, set)
}

func (h *handler) DeleteExample(w http.ResponseWriter, r *http.Request) {
	ctx := context.GetContext(r)
	req := example.NewDeleteExampleRequestWithID(ctx.PS.ByName("id"))
	set, err := h.service.DeleteExample(r.Context(), req)
	if err != nil {
		response.Failed(w, err)
		return
	}
	response.Success(w, set)
}