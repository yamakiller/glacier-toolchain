syntax = "proto3";

package {{.AppName}};
option go_package = "{{.PKG}}/apps/{{.AppName}}";

import "github.com/yamakiller/glacier-toolchain/pb/page/page.proto";
import "github.com/yamakiller/glacier-toolchain/pb/request/request.proto";

/*
示例代码
service Service {
    rpc Create{{.CapName}}(Create{{.CapName}}Request) returns({{.CapName}});
    rpc Query{{.CapName}}(Query{{.CapName}}Request) returns({{.CapName}}Set);
    rpc Describe{{.CapName}}(Describe{{.CapName}}Request) returns({{.CapName}});
    rpc Update{{.CapName}}(Update{{.CapName}}Request) returns({{.CapName}});
    rpc Delete{{.CapName}}(Delete{{.CapName}}Request) returns({{.CapName}});
}

// {{.CapName}} 示例数据
message {{.CapName}} {
    // 唯一ID
    // @gotags: json:"id" bson:"_id"
    string id = 1;
    // 录入时间
    // @gotags: json:"create_at" bson:"create_at"
    int64 create_at = 2;
    // 更新时间
    // @gotags: json:"update_at" bson:"update_at"
    int64 update_at = 3;
    // 更新人
    // @gotags: json:"update_by" bson:"update_by"
    string update_by = 4;
    // 信息
    // @gotags: json:"data" bson:"data"
    Create{{.CapName}}Request data = 5;
}

message Create{{.CapName}}Request {
    // 创建人
    // @gotags: json:"create_by" bson:"create_by"
    string create_by = 1;
    // 名称
    // @gotags: json:"name" bson:"name" validate:"required"
    string name = 2;
    // 作者
    // @gotags: json:"author" bson:"author" validate:"required"
    string author = 3;
}

message Query{{.CapName}}Request {
    // 分页参数
    // @gotags: json:"page"
    infraboard.mcube.page.PageRequest page = 1;
    // 关键字参数
    // @gotags: json:"keywords"
    string keywords = 2;
}

// {{.CapName}}Set 数据集
message {{.CapName}}Set {
    // 分页时，返回总数量
    // @gotags: json:"total"
    int64 total = 1;
    // 一页的数据
    // @gotags: json:"items"
    repeated {{.CapName}} items = 2;
}

message Describe{{.CapName}}Request {
    // {{.AppName}} id
    // @gotags: json:"id"
    string id = 1;
}

message Update{{.CapName}}Request {
    // {{.AppName}} id
    // @gotags: json:"id"
    string id = 1;
    // 更新模式
    // @gotags: json:"update_mode"
    yamakiller.glacier.toolchain.request.UpdateMode update_mode = 2;
    // 更新人
    // @gotags: json:"update_by"
    string update_by = 3;
    // 更新时间
    // @gotags: json:"update_at"
    int64 update_at = 4;
    // 更新的书本信息
    // @gotags: json:"data"
    Create{{.CapName}}Request data = 5;
}

message Delete{{.CapName}}Request {
    // {{.AppName}} id
    // @gotags: json:"id"
    string id = 1;
}*/