package impl

import (
	"context"
	"fmt"

	"{{.PKG}}/apps/{{.AppName}}"

{{ if $.EnableMongoDB -}}
	"github.com/yamakiller/glacier-toolchain/exception"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
{{- end }}
)

{{ if $.EnableMySQL -}}
func (s *service) delete{{.CapName}}(ctx context.Context, ins *{{.AppName}}.{{.CapName}}) error {
	if ins == nil || ins.Id == "" {
		return fmt.Errorf("{{.AppName}} is nil")
	}

	stmt := s.db.Session(&gorm.Session{PrepareStmt: true})
    defer stmt.Close()

    err = stmt.Exec(delete{{.CapName}}SQL, ins.Id).Error
    if err != nil {
        return err
    }

	return nil
}

func (s *service) update{{.CapName}}(ctx context.Context, ins *{{.AppName}}.{{.CapName}}) error {
	stmt := s.db.Session(&gorm.Session{PrepareStmt: true})
    defer stmt.Close()

    err = stmt.Exec(update{{.CapName}}SQL,
    		ins.UpdateAt, ins.UpdateBy, ins.Data.Name, ins.Data.Author, ins.Id).Error

	if err != nil {
		return err
	}

	return nil
}
{{- end }}

{{ if $.EnableMongoDB -}}
func (s *service) save(ctx context.Context, ins *{{.AppName}}.{{.CapName}}) error {
	if _, err := s.col.InsertOne(ctx, ins); err != nil {
		return exception.NewInternalServerError("inserted {{.AppName}}(%s) document error, %s",
			ins.Data.Name, err)
	}
	return nil
}

func (s *service) get(ctx context.Context, id string) (*{{.AppName}}.{{.CapName}}, error) {
	filter := bson.M{"_id": id}

	ins := {{.AppName}}.NewDefault{{.CapName}}()
	if err := s.col.FindOne(ctx, filter).Decode(ins); err != nil {
		if err == mongo.ErrNoDocuments {
			return nil, exception.NewNotFound("{{.AppName}} %s not found", id)
		}

		return nil, exception.NewInternalServerError("find {{.AppName}} %s error, %s", id, err)
	}

	return ins, nil
}

func newQuery{{.CapName}}Request(r *{{.AppName}}.Query{{.CapName}}Request) *query{{.CapName}}Request {
	return &query{{.CapName}}Request{
		r,
	}
}

type query{{.CapName}}Request struct {
	*{{.AppName}}.Query{{.CapName}}Request
}

func (r *query{{.CapName}}Request) FindOptions() *options.FindOptions {
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

func (r *query{{.CapName}}Request) FindFilter() bson.M {
	filter := bson.M{}
	if r.Keywords != "" {
		filter["$or"] = bson.A{
			bson.M{"data.name": bson.M{"$regex": r.Keywords, "$options": "im"}},
			bson.M{"data.author": bson.M{"$regex": r.Keywords, "$options": "im"}},
		}
	}
	return filter
}

func (s *service) query(ctx context.Context, req *query{{.CapName}}Request) (*{{.AppName}}.{{.CapName}}Set, error) {
	resp, err := s.col.Find(ctx, req.FindFilter(), req.FindOptions())
	if err != nil {
		return nil, exception.NewInternalServerError("find {{.AppName}} error, error is %s", err)
	}

	set := {{.AppName}}.New{{.CapName}}Set()
	// 循环
	for resp.Next(ctx) {
		ins := {{.AppName}}.NewDefault{{.CapName}}()
		if err := resp.Decode(ins); err != nil {
			return nil, exception.NewInternalServerError("decode {{.AppName}} error, error is %s", err)
		}

		set.Add(ins)
	}

	// count
	count, err := s.col.CountDocuments(ctx, req.FindFilter())
	if err != nil {
		return nil, exception.NewInternalServerError("get {{.AppName}} count error, error is %s", err)
	}
	set.Total = count

	return set, nil
}

func (s *service) update(ctx context.Context, ins *{{.AppName}}.{{.CapName}}) error {
	if _, err := s.col.UpdateByID(ctx, ins.Id, ins); err != nil {
		return exception.NewInternalServerError("inserted {{.AppName}}(%s) document error, %s",
			ins.Data.Name, err)
	}

	return nil
}

func (s *service) delete{{.CapName}}(ctx context.Context, ins *{{.AppName}}.{{.CapName}}) error {
	if ins == nil || ins.Id == "" {
		return fmt.Errorf("{{.AppName}} is nil")
	}

	result, err := s.col.DeleteOne(ctx, bson.M{"_id": ins.Id})
	if err != nil {
		return exception.NewInternalServerError("delete {{.AppName}}(%s) error, %s", ins.Id, err)
	}

	if result.DeletedCount == 0 {
		return exception.NewNotFound("{{.AppName}} %s not found", ins.Id)
	}

	return nil
}
{{- end }}