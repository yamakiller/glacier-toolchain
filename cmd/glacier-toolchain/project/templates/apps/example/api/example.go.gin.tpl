package api

import (
	"github.com/gin-gonic/gin"
	"github.com/yamakiller/glacier-toolchain/http/response"

	"{{.PKG}}/apps/example"
)

func (h *handler) CreateExample(c *gin.Context) {
	req := book.NewCreateExampleRequest()
	if err := c.BindJSON(req); err != nil {
		response.Failed(c.Writer, err)
		return
	}

	set, err := h.service.CreateExample(c.Request.Context(), req)
	if err != nil {
		response.Failed(c.Writer, err)
		return
	}

	response.Success(c.Writer, set)
}

func (h *handler) QueryExample(c *gin.Context) {
	req := book.NewQueryExampleRequestFromHTTP(c.Request)
	set, err := h.service.QueryExample(c.Request.Context(), req)
	if err != nil {
		response.Failed(c.Writer, err)
		return
	}
	response.Success(c.Writer, set)
}

func (h *handler) DescribeExample(c *gin.Context) {
	req := book.NewDescribeExampleRequest(c.Param("id"))
	ins, err := h.service.DescribeExample(c.Request.Context(), req)
	if err != nil {
		response.Failed(c.Writer, err)
		return
	}

	response.Success(c.Writer, ins)
}

func (h *handler) PutExample(c *gin.Context) {
	req := book.NewPutExampleRequest(c.Param("id"))
	if err := c.BindJSON(req.Data); err != nil {
		response.Failed(c.Writer, err)
		return
	}

	set, err := h.service.UpdateExample(c.Request.Context(), req)
	if err != nil {
		response.Failed(c.Writer, err)
		return
	}
	response.Success(c.Writer, set)
}

func (h *handler) PatchExample(c *gin.Context) {
	req := book.NewPatchExampleRequest(c.Param("id"))
	if err := c.BindJSON(req.Data); err != nil {
		response.Failed(c.Writer, err)
		return
	}

	set, err := h.service.UpdateExample(c.Request.Context(), req)
	if err != nil {
		response.Failed(c.Writer, err)
		return
	}
	response.Success(c.Writer, set)
}

func (h *handler) DeleteExample(c *gin.Context) {
	req := book.NewDeleteExampleRequestWithID(c.Param("id"))
	set, err := h.service.DeleteExample(c.Request.Context(), req)
	if err != nil {
		response.Failed(c.Writer, err)
		return
	}
	response.Success(c.Writer, set)
}