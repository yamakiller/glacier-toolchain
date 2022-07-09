# glacier-toolchain
微服务工具箱, 构建微服务中使用的工具集  
- http框架: 用于构建领域服务的路由框架, 基于httprouter进行封装
- 日志处理: 封装zap, 用于日志处理
- 加密解密: 封装cbc和ecies
- 服务注册: 服务注册组件
- 缓存处理: redis用于构建多级对象缓存
- 链路追踪: glacier-toolchain提供的组件都内置了链路追踪

# 使用说明
快速安装  
```
go install github.com/yamakiller/glacier-toolchain/cmd/glacier-toolchain 
```
使用指令
```
glacier-toolchain -h

Usage:
    toolchain [flags]
    toolchain [command]

Available Commands:
enum        枚举生成器
help        显示帮助信息
init        初始化

Flags:
-h, --help      显示工具帮助信息
-v, --version   显示工具版本信息

Use "glacier-toolchain [command] --help" 显示更多关于命令的帮助信息.
```
- 枚举生成器（如下测试用例）
```
package enum_test

const (
// Running (running) todo
Running Status = iota
// Stopping (stopping) tdo
Stopping
// Stopped (stopped) todo
Stopped
// Canceled (canceled) todo
Canceled

	test11
)

const (
// Running (running) todo
E1 Enum = iota
// Running (running) todo
E2
)

// Status AAA
// BBB
type Status uint

type Enum uint
```
执行生成器  
```
go generate ./...
```

生成如下:  
```
package enum_test

import (
	"bytes"
	"fmt"
	"strings"
)

var (
	enumStatusShowMap = map[Status]string{
		Running:  "Running",
		Stopping: "Stopping",
		Stopped:  "Stopped",
		Canceled: "Canceled",
		test11:   "test11",
	}

	enumStatusIDMap = map[string]Status{
		"Running":  Running,
		"Stopping": Stopping,
		"Stopped":  Stopped,
		"Canceled": Canceled,
		"test11":   test11,
	}
)

// ParseStatus Parse Status from string
func ParseStatus(str string) (Status, error) {
	key := strings.Trim(string(str), `"`)
	v, ok := enumStatusIDMap[key]
	if !ok {
		return 0, fmt.Errorf("unknown Status: %s", str)
	}

	return v, nil
}

// Is todo
func (t Status) Is(target Status) bool {
	return t == target
}

// String stringer
func (t Status) String() string {
	v, ok := enumStatusShowMap[t]
	if !ok {
		return "unknown"
	}

	return v
}

// MarshalJSON 序列化
func (t Status) MarshalJSON() ([]byte, error) {
	b := bytes.NewBufferString(`"`)
	b.WriteString(t.String())
	b.WriteString(`"`)
	return b.Bytes(), nil
}

// UnmarshalJSON 反序列化
func (t *Status) UnmarshalJSON(b []byte) error {
	ins, err := ParseStatus(string(b))
	if err != nil {
		return err
	}
	*t = ins
	return nil
}

var (
	enumEnumShowMap = map[Enum]string{
		E1: "E1",
		E2: "E2",
	}

	enumEnumIDMap = map[string]Enum{
		"E1": E1,
		"E2": E2,
	}
)

// ParseEnum Parse Enum from string
func ParseEnum(str string) (Enum, error) {
	key := strings.Trim(string(str), `"`)
	v, ok := enumEnumIDMap[key]
	if !ok {
		return 0, fmt.Errorf("unknown Status: %s", str)
	}

	return v, nil
}

// Is 是否相等
func (t Enum) Is(target Enum) bool {
	return t == target
}

// String stringer
func (t Enum) String() string {
	v, ok := enumEnumShowMap[t]
	if !ok {
		return "unknown"
	}

	return v
}

// MarshalJSON 序列化
func (t Enum) MarshalJSON() ([]byte, error) {
	b := bytes.NewBufferString(`"`)
	b.WriteString(t.String())
	b.WriteString(`"`)
	return b.Bytes(), nil
}

// UnmarshalJSON 反序列化
func (t *Enum) UnmarshalJSON(b []byte) error {
	ins, err := ParseEnum(string(b))
	if err != nil {
		return err
	}
	*t = ins
	return nil
}
```
创建项目
```
glacier-toolchain project init
```