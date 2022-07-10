package impl

import (
	"context"
{{ if $.EnableMySQL -}}
	"database/sql"
{{- end }}

	"github.com/yamakiller/glacier-toolchain/exception"
	"github.com/yamakiller/glacier-toolchain/pb/request"
{{ if $.EnableMySQL -}}
	"github.com/yamakiller/glacier-toolchain/sqlbuilder"
{{- end }}

	"{{.PKG}}/apps/example"
)

{{ if $.EnableMySQL -}}
func (s *service) CreateExample(ctx context.Context, req *example.CreateExampleRequest) (
	*example.Example, error) {
	ins, err := example.NewExample(req)
	if err != nil {
		return nil, exception.NewBadRequest("validate create example error, %s", err)
	}

	stmt = s.db.Session(&gorm.Session{PrepareStmt: true})
	defer stmt.Close()

	err = stmt.Exec(insertExampleSQL,
                   ins.Id, ins.CreateAt, ins.Data.CreateBy, ins.UpdateAt, ins.UpdateBy,
                   ins.Data.Name, ins.Data.Author).Error
    if err != nil {
        return nil, err
    }

    return ins, nil
}

func (s *service) QueryExample(ctx context.Context, req *book.QueryExampleRequest) (
	*example.ExampleSet, error) {
	query := sqlbuilder.NewQuery(queryExampleSQL)
	// 支持关键字参数
	if req.Keywords != "" {
		query.Where("name LIKE ? OR author = ?",
			"%"+req.Keywords+"%",
			req.Keywords,
		)
	}

	querySQL, args := query.Order("create_at").Desc().Limit(req.Page.ComputeOffset(), uint(req.Page.PageSize)).BuildQuery()
	s.log.Debugf("sql: %s, args: %v", querySQL, args)

    queryStmt := s.db.Session(&gorm.Session{PrepareStmt: true})
    defer queryStmt.Close()

    rows, err := queryStmt.Raw(querySQL, args...).Rows()
    if err != nil {
        return nil, exception.NewInternalServerError(err.Error())
    }
    defer rows.Close()

	set := example.NewExampleSet()
    for rows.Next() {
        ins := example.NewDefaultExample()
        err := rows.Scan(
            &ins.Id, &ins.CreateAt, &ins.Data.CreateBy, &ins.UpdateAt, &ins.UpdateBy,
            &ins.Data.Name, &ins.Data.Author,
        )
        if err != nil {
            return nil, exception.NewInternalServerError("query book error, %s", err.Error())
        }
        set.Add(ins)
    }

    // 获取total SELECT COUNT(*) FROMT t Where ....
    countSQL, args := query.BuildCount()
    countStmt := s.db.Session(&gorm.Session{PrepareStmt: true})
    defer countStmt.Close()

    err = countStmt.Raw(countSQL, args...).Scan(&set.Total)
    if err != nil {
        return nil, exception.NewInternalServerError(err.Error())
    }

    return set, nil
}

func (s *service) DescribeExample(ctx context.Context, req *example.DescribeExampleRequest) (
	*example.Example, error) {
	query := sqlbuilder.NewQuery(queryExampleSQL)
	querySQL, args := query.Where("id = ?", req.Id).BuildQuery()
	s.log.Debugf("sql: %s", querySQL)

    queryStmt := s.db.Session(&gorm.Session{PrepareStmt: true})
    defer queryStmt.Close()

	ins := example.NewDefaultExample()
	err = queryStmt.Raw(querySQL, args...).Scan(
		&ins.Id, &ins.CreateAt, &ins.Data.CreateBy, &ins.UpdateAt, &ins.UpdateBy,
		&ins.Data.Name, &ins.Data.Author,
	)

	if err != nil {
		if err == sql.ErrNoRows {
			return nil, exception.NewNotFound("%s not found", req.Id)
		}
		return nil, exception.NewInternalServerError("describe book error, %s", err.Error())
	}

	return ins, nil
}

func (s *service) UpdateExample(ctx context.Context, req *book.UpdateExampleRequest) (
	*example.Example, error) {
	ins, err := s.DescribeExample(ctx, book.NewDescribeExampleRequest(req.Id))
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

	if err := s.updateExample(ctx, ins); err != nil {
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
{{- end }}

{{ if $.EnableMongoDB -}}
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

func (s *service) DescribeExample(ctx context.Context, req *book.DescribeExampleRequest) (
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
	ins, err := s.DescribeExample(ctx, book.NewDescribeExampleRequest(req.Id))
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
{{- end }}