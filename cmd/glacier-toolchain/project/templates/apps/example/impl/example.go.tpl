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

	"{{.PKG}}/apps/{{.AppName}}"
)

{{ if $.EnableMySQL -}}
func (s *service) Create{{.CapName}}(ctx context.Context, req *{{.AppName}}.Create{{.CapName}}Request) (
	*{{.AppName}}.{{.CapName}}, error) {
	ins, err := {{.AppName}}.New{{.CapName}}(req)
	if err != nil {
		return nil, exception.NewBadRequest("validate create {{.AppName}} error, %s", err)
	}

	stmt = s.db.Session(&gorm.Session{PrepareStmt: true})
	defer stmt.Close()

	err = stmt.Exec(insert{{.CapName}}SQL,
                   ins.Id, ins.CreateAt, ins.Data.CreateBy, ins.UpdateAt, ins.UpdateBy,
                   ins.Data.Name, ins.Data.Author).Error
    if err != nil {
        return nil, err
    }

    return ins, nil
}

func (s *service) Query{{.CapName}}(ctx context.Context, req *{{.AppName}}.Query{{.CapName}}Request) (
	*{{.AppName}}.{{.CapName}}Set, error) {
	query := sqlbuilder.NewQuery(query{{.CapName}}SQL)
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

	set := {{.AppName}}.New{{.CapName}}Set()
    for rows.Next() {
        ins := {{.AppName}}.NewDefault{{.CapName}}()
        err := rows.Scan(
            &ins.Id, &ins.CreateAt, &ins.Data.CreateBy, &ins.UpdateAt, &ins.UpdateBy,
            &ins.Data.Name, &ins.Data.Author,
        )
        if err != nil {
            return nil, exception.NewInternalServerError("query {{.AppName}} error, %s", err.Error())
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

func (s *service) Describe{{.CapName}}(ctx context.Context, req *{{.AppName}}.Describe{{.CapName}}Request) (
	*{{.AppName}}.{{.CapName}}, error) {
	query := sqlbuilder.NewQuery(query{{.CapName}}SQL)
	querySQL, args := query.Where("id = ?", req.Id).BuildQuery()
	s.log.Debugf("sql: %s", querySQL)

    queryStmt := s.db.Session(&gorm.Session{PrepareStmt: true})
    defer queryStmt.Close()

	ins := {{.AppName}}.NewDefault{{.CapName}}()
	err = queryStmt.Raw(querySQL, args...).Scan(
		&ins.Id, &ins.CreateAt, &ins.Data.CreateBy, &ins.UpdateAt, &ins.UpdateBy,
		&ins.Data.Name, &ins.Data.Author,
	)

	if err != nil {
		if err == sql.ErrNoRows {
			return nil, exception.NewNotFound("%s not found", req.Id)
		}
		return nil, exception.NewInternalServerError("describe {{.AppName}} error, %s", err.Error())
	}

	return ins, nil
}

func (s *service) Update{{.CapName}}(ctx context.Context, req *{{.AppName}}.Update{{.CapName}}Request) (
	*{{.AppName}}.{{.CapName}}, error) {
	ins, err := s.Describe{{.CapName}}(ctx, {{.AppName}}.NewDescribe{{.CapName}}Request(req.Id))
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

	if err := s.update{{.CapName}}(ctx, ins); err != nil {
		return nil, err
	}

	return ins, nil
}

func (s *service) Delete{{.CapName}}(ctx context.Context, req *{{.AppName}}.Delete{{.CapName}}Request) (
	*{{.AppName}}.{{.CapName}}, error) {
	ins, err := s.Describe{{.CapName}}(ctx, {{.AppName}}.NewDescribe{{.CapName}}Request(req.Id))
	if err != nil {
		return nil, err
	}

	if err := s.delete{{.CapName}}(ctx, ins); err != nil {
		return nil, err
	}

	return ins, nil
}
{{- end }}

{{ if $.EnableMongoDB -}}
func (s *service) Create{{.CapName}}(ctx context.Context, req *{{.AppName}}.Create{{.CapName}}Request) (
	*{{.AppName}}.{{.CapName}}, error) {
	ins, err := {{.AppName}}.New{{.CapName}}(req)
	if err != nil {
		return nil, exception.NewBadRequest("validate create {{.AppName}} error, %s", err)
	}

	if err := s.save(ctx, ins); err != nil {
		return nil, err
	}

	return ins, nil
}

func (s *service) Describe{{.CapName}}(ctx context.Context, req *{{.AppName}}.Describe{{.CapName}}Request) (
	*{{.AppName}}.{{.CapName}}, error) {
	return s.get(ctx, req.Id)
}

func (s *service) Query{{.CapName}}(ctx context.Context, req *{{.AppName}}.Query{{.CapName}}Request) (
	*{{.AppName}}.{{.CapName}}Set, error) {
	query := newQuery{{.CapName}}Request(req)
	return s.query(ctx, query)
}

func (s *service) Update{{.CapName}}(ctx context.Context, req *{{.AppName}}.Update{{.CapName}}Request) (
	*{{.AppName}}.{{.CapName}}, error) {
	ins, err := s.Describe{{.CapName}}(ctx, {{.AppName}}.NewDescribe{{.CapName}}Request(req.Id))
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

func (s *service) Delete{{.CapName}}(ctx context.Context, req *{{.AppName}}.Delete{{.CapName}}Request) (
	*{{.AppName}}.{{.CapName}}, error) {
	ins, err := s.Describe{{.CapName}}(ctx, {{.AppName}}.NewDescribe{{.CapName}}Request(req.Id))
	if err != nil {
		return nil, err
	}

	if err := s.delete{{.CapName}}(ctx, ins); err != nil {
		return nil, err
	}

	return ins, nil
}
{{- end }}