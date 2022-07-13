# glacier-toolchain

微服务工具箱, 构建微服务中使用的工具集  
- http框架: 用于构建领域服务的路由框架, 基于httprouter进行封装
- 异常处理: 定义API Exception
- 日志处理: 封装zap, 用于日志处理
- 加密解密: 封装cbc和ecies
- 自定义类型: ftime方便控制时间序列化的类型, set集合
- 服务注册: 服务注册组件
- 缓存处理: 用于构建多级对象缓存
- 事件总线: 用于系统事件订阅与发布
- 链路追踪: 工具链提供的组件都内置了链路追踪
快速上手
首先你需要安装工具链, 所有的功能都集成到这个CLI工具上了
````
 go install github.com/yamakiller/glacier-toolchain/cmd/glacier-toolchain
````
按照完成后, 通过help指令查看基本使用方法

````
$ glacier-toolchain -h
glacier-toolchain ...

Usage:
glacier-toolchain [flags]
glacier-toolchain [command]

Available Commands:
enum        枚举生成器
help        Help about any command
init        初始化

Flags:
-h, --help      help for glacier-toolchain
-v, --version   the glacier-toolchain version

Use "glacier-toolchain [command] --help" for more information about a command.
````

启用看一看  

````
$ make run
2020-06-06T20:03:00.328+0800    INFO    [INIT]  cmd/service.go:151      log level: debug
2020-06-06T20:03:00.328+0800    INFO    [CLI]   cmd/service.go:93       loaded services: []
Version   :
Build Time:
Git Branch:
Git Commit:
Go Version:

2020-06-06T20:03:00.328+0800    INFO    [API]   api/api.go:66   http endpoint registry success
2020-06-06T20:03:00.328+0800    INFO    [API]   api/api.go:100  HTTP服务启动成功, 监听地址: 0.0.0.0:8050
````

提升效率自动化的生成  
创建项目
````
glacier-toolchain project init
````
构建协议
````
glacier-toolchain proto generate --bin=<proto可执行文件> --include=<proto 基础库文件> --pkg=<项目包名> <需要搜索的路径>
例如:
glacier-toolchain proto generate --bin=./bin/protoc.exe --include=./bin/protobuf/include --pkg=github.com/yamakiller/glacier-center  apps/*/pb/*.proto
````
构建协议标签
````
glacier-toolchain proto generate-tag <需要搜索的路径>
例如:
glacier-toolchain proto generate-tag apps/*/*.pb.go
````
构建enum
````
glacier-toolchain generate enum <-m:是否生成编解码> <-p:是否构建协议扩展> <构建文件路径>
例如:
glacier-toolchain generate enum -p -m apps/*/*.pb.go
````
构建Proto http
````
protoc --proto_path=. --proto_path=<GOPATH/src> --go-http_out=<生成文件输出路径> --go-http_opt=module="<项目包名>" <需要生成的协议文件>
例如:
protoc.exe --proto_path=. --proto_path= D:\workspace\go\src --go-http_out=. --go-http_opt=module="github.com/yamakiller/glacier-auth" apps/application/pb/service.proto
````