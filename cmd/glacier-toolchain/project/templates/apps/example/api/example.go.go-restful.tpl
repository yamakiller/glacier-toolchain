package api

import (
	"github.com/emicklei/go-restful/v3"
	"github.com/yamakiller/glacier-toolchain/http/response"

	"{{.PKG}}/apps/example"
)

func (h *handler) CreateExample(r *restful.Request, w *restful.Response) {
	req := example.NewCreateExampleRequest()
	if err := r.ReadEntity(req); err != nil {
		response.Failed(w.ResponseWriter, err)
		return
	}

	set, err := h.service.CreateExample(r.Request.Context(), req)
	if err != nil {
		response.Failed(w.ResponseWriter, err)
		return
	}

	response.Success(w.ResponseWriter, set)
}

func (h *handler) QueryExample(r *restful.Request, w *restful.Response) {
	req := book.NewQueryExampleRequestFromHTTP(r.Request)
	set, err := h.service.QueryExample(r.Request.Context(), req)
	if err != nil {
		response.Failed(w.ResponseWriter, err)
		return
	}
	response.Success(w.ResponseWriter, set)
}

func (h *handler) DescribeExample(r *restful.Request, w *restful.Response) {
	req := book.NewDescribeExampleRequest(r.PathParameter("id"))
	ins, err := h.service.DescribeExample(r.Request.Context(), req)
	if err != nil {
		response.Failed(w.ResponseWriter, err)
		return
	}

	response.Success(w.ResponseWriter, ins)
}

func (h *handler) UpdateExample(r *restful.Request, w *restful.Response) {
	req := book.NewPutExampleRequest(r.PathParameter("id"))
	if err := r.ReadEntity(req.Data); err != nil {
		response.Failed(w.ResponseWriter, err)
		return
	}

	set, err := h.service.UpdateExample(r.Request.Context(), req)
	if err != nil {
		response.Failed(w.ResponseWriter, err)
		return
	}
	response.Success(w.ResponseWriter, set)
}

func (h *handler) PatchExample(r *restful.Request, w *restful.Response) {
	req := example.NewPatchExampleRequest(r.PathParameter("id"))
	if err := r.ReadEntity(req.Data); err != nil {
		response.Failed(w.ResponseWriter, err)
		return
	}

	set, err := h.service.UpdateExample(r.Request.Context(), req)
	if err != nil {
		response.Failed(w.ResponseWriter, err)
		return
	}
	response.Success(w.ResponseWriter, set)
}

func (h *handler) DeleteExample(r *restful.Request, w *restful.Response) {
	req := example.NewDeleteExampleRequestWithID(r.PathParameter("id"))
	set, err := h.service.DeleteExample(r.Request.Context(), req)
	if err != nil {
		response.Failed(w.ResponseWriter, err)
		return
	}
	response.Success(w.ResponseWriter, set)
}