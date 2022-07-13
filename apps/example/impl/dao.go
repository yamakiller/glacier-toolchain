package impl

import (
	"context"
	"fmt"

	"github.com/yamakiller/glacier-toolchain/apps/example"

"github.com/yamakiller/glacier-toolchain/exception"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)



func (s *service) save(ctx context.Context, ins *example.Example) error {
	if _, err := s.col.InsertOne(ctx, ins); err != nil {
		return exception.NewInternalServerError("inserted example(%s) document error, %s",
			ins.Data.Name, err)
	}
	return nil
}

func (s *service) get(ctx context.Context, id string) (*example.Example, error) {
	filter := bson.M{"_id": id}

	ins := example.NewDefaultExample()
	if err := s.col.FindOne(ctx, filter).Decode(ins); err != nil {
		if err == mongo.ErrNoDocuments {
			return nil, exception.NewNotFound("example %s not found", id)
		}

		return nil, exception.NewInternalServerError("find example %s error, %s", id, err)
	}

	return ins, nil
}

func newQueryExampleRequest(r *example.QueryExampleRequest) *queryExampleRequest {
	return &queryExampleRequest{
		r,
	}
}

type queryExampleRequest struct {
	*example.QueryExampleRequest
}

func (r *queryExampleRequest) FindOptions() *options.FindOptions {
	pageSize := int64(r.Page.PageSize)
	skip := int64(r.Page.PageSize) * int64(r.Page.PageNumber-1)
	opt := &options.FindOptions{
		Sort: bson.D{
			{Key: "create_at", Value: -1},
		},
		Limit: &pageSize,
		Skip:  &skip,
	}

	return opt
}

func (r *queryExampleRequest) FindFilter() bson.M {
	filter := bson.M{}
	if r.Keywords != "" {
		filter["$or"] = bson.A{
			bson.M{"data.name": bson.M{"$regex": r.Keywords, "$options": "im"}},
			bson.M{"data.author": bson.M{"$regex": r.Keywords, "$options": "im"}},
		}
	}
	return filter
}

func (s *service) query(ctx context.Context, req *queryExampleRequest) (*example.ExampleSet, error) {
	resp, err := s.col.Find(ctx, req.FindFilter(), req.FindOptions())
	if err != nil {
		return nil, exception.NewInternalServerError("find example error, error is %s", err)
	}

	set := example.NewExampleSet()
	// 循环
	for resp.Next(ctx) {
		ins := example.NewDefaultExample()
		if err := resp.Decode(ins); err != nil {
			return nil, exception.NewInternalServerError("decode example error, error is %s", err)
		}

		set.Add(ins)
	}

	// count
	count, err := s.col.CountDocuments(ctx, req.FindFilter())
	if err != nil {
		return nil, exception.NewInternalServerError("get example count error, error is %s", err)
	}
	set.Total = count

	return set, nil
}

func (s *service) update(ctx context.Context, ins *example.Example) error {
	if _, err := s.col.UpdateByID(ctx, ins.Id, ins); err != nil {
		return exception.NewInternalServerError("inserted example(%s) document error, %s",
			ins.Data.Name, err)
	}

	return nil
}

func (s *service) deleteExample(ctx context.Context, ins *example.Example) error {
	if ins == nil || ins.Id == "" {
		return fmt.Errorf("example is nil")
	}

	result, err := s.col.DeleteOne(ctx, bson.M{"_id": ins.Id})
	if err != nil {
		return exception.NewInternalServerError("delete example(%s) error, %s", ins.Id, err)
	}

	if result.DeletedCount == 0 {
		return exception.NewNotFound("example %s not found", ins.Id)
	}

	return nil
}