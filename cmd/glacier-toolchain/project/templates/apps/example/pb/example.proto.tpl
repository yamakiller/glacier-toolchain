syntax = "proto3";

package {{.AppName}};
option go_package = "{{.PKG}}/apps/{{.AppName}}";

import "github.com/yamakiller/glacier-toolchain/pb/page/page.proto";
import "github.com/yamakiller/glacier-toolchain/pb/request/request.proto";

示例代码
service Service {
    //TODO: 加入服务定义
}

// {{.CapName}} 示例数据
message {{.CapName}} {
    //TODO: 加入消息定义
}