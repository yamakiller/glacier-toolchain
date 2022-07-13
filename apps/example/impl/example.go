package impl

import (
	"context"

    "github.com/yamakiller/glacier-toolchain/exception"
	"github.com/yamakiller/glacier-toolchain/pb/request"


	"github.com/yamakiller/glacier-toolchain/apps/example"
)



func (s *service) CreateExample(ctx context.Context, req *example.CreateExampleRequest) (
	*example.Example, error) {
	ins, err := example.NewExample(req)
	if err != nil {
		return nil, exception.NewBadRequest("validate create example error, %s", err)
	}

	if err := s.save(ctx, ins); err != nil {
		return nil, err
	}

	return ins, nil
}

func (s *service) DescribeExample(ctx context.Context, req *example.DescribeExampleRequest) (
	*example.Example, error) {
	return s.get(ctx, req.Id)
}

func (s *service) QueryExample(ctx context.Context, req *example.QueryExampleRequest) (
	*example.ExampleSet, error) {
	query := newQueryExampleRequest(req)
	return s.query(ctx, query)
}

func (s *service) UpdateExample(ctx context.Context, req *example.UpdateExampleRequest) (
	*example.Example, error) {
	ins, err := s.DescribeExample(ctx, example.NewDescribeExampleRequest(req.Id))
	if err != nil {
		return nil, err
	}

	switch req.UpdateMode {
	case request.UpdateMode_PUT:
		ins.Update(req)
	case request.UpdateMode_PATCH:
		err := ins.Patch(req)
		if err != nil {
			return nil, err
		}
	}

	// 校验更新后数据合法性
	if err := ins.Data.Validate(); err != nil {
		return nil, err
	}

	if err := s.update(ctx, ins); err != nil {
		return nil, err
	}

	return ins, nil
}

func (s *service) DeleteExample(ctx context.Context, req *example.DeleteExampleRequest) (
	*example.Example, error) {
	ins, err := s.DescribeExample(ctx, example.NewDescribeExampleRequest(req.Id))
	if err != nil {
		return nil, err
	}

	if err := s.deleteExample(ctx, ins); err != nil {
		return nil, err
	}

	return ins, nil
}