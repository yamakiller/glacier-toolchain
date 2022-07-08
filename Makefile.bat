SET PROJECT_NAME=tbx
SET PKG=github.com/yamakiller/glacier.devops.%PROJECT_NAME%

protoc -I=. -I=%GOPATH%\src -I=protobuf\include --go_out=. --go_opt=module=%PKG% --go-grpc_out=. --go-grpc_opt=module=%PKG% pb/http/*.proto
protoc -I=. -I=%GOPATH%\src -I=protobuf\include --go_out=. --go_opt=module=%PKG% --go-grpc_out=. --go-grpc_opt=module=%PKG% pb/request/*.proto
protoc -I=. -I=%GOPATH%\src -I=protobuf\include --go_out=. --go_opt=module=%PKG% --go-grpc_out=. --go-grpc_opt=module=%PKG% pb/resource/*.proto
protoc -I=. -I=%GOPATH%\src -I=protobuf\include --go_out=. --go_opt=module=%PKG% --go-grpc_out=. --go-grpc_opt=module=%PKG% pb/response/*.proto

protoc-go-inject-tag -input=pb/http/*.pb.go
