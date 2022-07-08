package array

import (
	"database/sql/driver"
	"encoding/json"
	"fmt"
	"strings"
)

var (
	// Separator 序列化时的分隔符
	Separator = ";"
	// StartEndMark 开始和结尾标志
	StartEndMark = ";"
)

// NewStringArray 实例化一个字符串形式的数组
func NewStringArray(items []string) *StringArray {
	return &StringArray{
		items: items,
	}
}

// StringArray 字符串数组对象
type StringArray struct {
	items []string
}

func (t *StringArray) add(item string) {
	if item != "" {
		t.items = append(t.items, item)
	}
}

// Items 列表
func (t StringArray) Items() []string {
	return t.items
}

// Length 长度
func (t StringArray) Length() int {
	return len(t.items)
}

// String 返回以分隔符组成的数组
func (t StringArray) String() string {
	if t.Length() == 0 {
		return ""
	}

	return StartEndMark + strings.Join(t.items, Separator) + StartEndMark
}

// Scan 实现sql的反序列化
func (t *StringArray) Scan(value interface{}) error {
	if value == nil {
		return nil
	}

	switch data := value.(type) {
	case []byte:
		raw := string(data)
		if raw == "" {
			t.items = []string{}
			return nil
		}
		for _, item := range strings.Split(raw, ";") {
			t.add(item)
		}
		return nil
	default:
		return fmt.Errorf("unsupport type: %s", data)
	}
}

// Value 实现str的序列化
func (t StringArray) Value() (driver.Value, error) {
	return t.String(), nil
}

// MarshalJSON todo
func (t StringArray) MarshalJSON() ([]byte, error) {
	return json.Marshal(t.items)
}

// UnmarshalJSON todo
func (t *StringArray) UnmarshalJSON(b []byte) error {
	return json.Unmarshal(b, &t.items)
}
