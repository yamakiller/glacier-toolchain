ECHO OFF
SET TOOLCHAIN_MAIN=cmd/glacier-toolchain/main.go
SET PROTOC_GEN_GO_HTTP_MAIN=cmd/protoc-gen-go-http/main.go

SET PROJECT_NAME=glacier-toolchain
SET PKG=github.com/yamakiller/%PROJECT_NAME%

IF %1==install GOTO INSTALL
IF %1==build GOTO BUILD
IF %1==dep GOTO DEP
IF %1==vet GOTO VET
IF %1==clean GOTO CLEAN
IF %1==gen GOTO GEN

:INSTALL
    go install %PKG%/cmd/glacier-toolchain
    GOTO DONE

:DEP
    go mod download
    GOTO DONE

:VET
    for /F %%i in ('go list %PKG%/...') ^
    do (
        go vet %%i
    )
    GOTO DONE

:BUILD
    go mod download
    go build -o build/%PROJECT_NAME% %TOOLCHAIN_MAIN%
    GOTO DONE

:CLEAN
    del build\* /q /f /s
    GOTO DONE

:GEN
    .\bin\protoc.exe -I=. -I=%GOPATH%\src -I=bin\protobuf\include --go_out=. --go_opt=module=%PKG% --go-grpc_out=. --go-grpc_opt=module=%PKG% pb/http/*.proto
    .\bin\protoc.exe -I=. -I=%GOPATH%\src -I=bin\protobuf\include --go_out=. --go_opt=module=%PKG% --go-grpc_out=. --go-grpc_opt=module=%PKG% pb/page/*.proto
    .\bin\protoc.exe -I=. -I=%GOPATH%\src -I=bin\protobuf\include --go_out=. --go_opt=module=%PKG% --go-grpc_out=. --go-grpc_opt=module=%PKG% pb/request/*.proto
    .\bin\protoc.exe -I=. -I=%GOPATH%\src -I=bin\protobuf\include --go_out=. --go_opt=module=%PKG% --go-grpc_out=. --go-grpc_opt=module=%PKG% pb/resource/*.proto
    .\bin\protoc.exe -I=. -I=%GOPATH%\src -I=bin\protobuf\include --go_out=. --go_opt=module=%PKG% --go-grpc_out=. --go-grpc_opt=module=%PKG% pb/response/*.proto

    ::protoc-go-inject-tag -input=pb/http/*.pb.go
    GOTO DONE
:DONE
ECHO Done!
