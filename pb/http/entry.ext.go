package http

import (
	"fmt"
	"strings"
)

// EntryDecorator 装饰
type EntryDecorator interface {
	//AddLabel 设置子路由标签, 作用于Entry上
	AddLabel(...*Label) EntryDecorator
	EnableAuth() EntryDecorator
	DisableAuth() EntryDecorator
	EnablePermission() EntryDecorator
	DisablePermission() EntryDecorator
	SetAllow(targets ...fmt.Stringer) EntryDecorator
	EnableAuditLog() EntryDecorator
	DisableAuditLog() EntryDecorator
	EnableRequreNamespace() EntryDecorator
	DisableRequiredNamespace() EntryDecorator
}

// NewEntry 行健条目
func NewEntry(path, method, resource string) *Entry {
	return &Entry{
		Path:     path,
		Method:   method,
		Resource: resource,
		Labels:   map[string]string{},
	}
}

func (x *Entry) Copy() *Entry {
	obj := new(Entry)
	*obj = *x
	return obj
}

// AddLabel 添加Label
func (x *Entry) AddLabel(labels ...*Label) EntryDecorator {
	for i := range labels {
		x.Labels[labels[i].Key()] = labels[i].Value()
	}

	return x
}

// GetLableValue 获取Lable的值
func (x *Entry) GetLableValue(key string) string {
	v, ok := x.Labels[key]
	if ok {
		return v
	}
	return ""
}

// EnableAuth 启动身份验证
func (x *Entry) EnableAuth() EntryDecorator {
	x.AuthEnable = true
	return x
}

// DisableAuth 不启用身份验证
func (x *Entry) DisableAuth() EntryDecorator {
	x.AuthEnable = false
	return x
}

// EnablePermission 启用授权验证
func (x *Entry) EnablePermission() EntryDecorator {
	x.PermissionEnable = true
	return x
}

// DisablePermission 禁用授权验证
func (x *Entry) DisablePermission() EntryDecorator {
	x.PermissionEnable = false
	return x
}

// SetAllow 设置添加的允许的target
func (x *Entry) SetAllow(targets ...fmt.Stringer) EntryDecorator {
	for i := range targets {
		x.Allow = append(x.Allow, targets[i].String())
	}
	return x
}

//EnableAuditLog EnableAuth 启动身份验证
func (x *Entry) EnableAuditLog() EntryDecorator {
	x.AuditLog = true
	return x
}

//DisableAuditLog DisableAuth 不启用身份验证
func (x *Entry) DisableAuditLog() EntryDecorator {
	x.AuditLog = false
	return x
}

//EnableRequreNamespace EnableAuth 启动身份验证
func (x *Entry) EnableRequreNamespace() EntryDecorator {
	x.RequiredNamespace = true
	return x
}

//DisableRequiredNamespace DisableAuth 不启用身份验证
func (x *Entry) DisableRequiredNamespace() EntryDecorator {
	x.RequiredNamespace = false
	return x
}

// UniquePath todo
func (x *Entry) UniquePath() string {
	return fmt.Sprintf("%s.%s", x.Method, x.Path)
}

func (x *Entry) IsAllow(target fmt.Stringer) bool {
	for i := range x.Allow {
		if x.Allow[i] == "*" {
			return true
		}

		if x.Allow[i] == target.String() {
			return true
		}
	}

	return false
}

// NewEntrySet 实例
func NewEntrySet() *EntrySet {
	return &EntrySet{}
}

// EntrySet 路由条目集
type EntrySet struct {
	Items []*Entry `json:"items"`
}

// PermissionEnableEntry todo
func (s *EntrySet) PermissionEnableEntry() []*Entry {
	var items []*Entry
	for i := range s.Items {
		if s.Items[i].PermissionEnable {
			items = append(items, s.Items[i])
		}
	}

	return items
}

// AuthEnableEntry todo
func (s *EntrySet) AuthEnableEntry() []*Entry {
	var items []*Entry
	for i := range s.Items {
		if s.Items[i].AuthEnable {
			items = append(items, s.Items[i])
		}
	}

	return items
}

func (s *EntrySet) String() string {
	var strs []string
	for i := range s.Items {
		strs = append(strs, s.Items[i].String())
	}

	return strings.Join(strs, "\n")
}

// Merge todo
func (s *EntrySet) Merge(target *EntrySet) {
	for i := range target.Items {
		s.Items = append(s.Items, target.Items[i])
	}
}

// AddEntry 添加Entry
func (s *EntrySet) AddEntry(es ...Entry) {
	for i := range es {
		s.Items = append(s.Items, &es[i])
	}
}

// GetEntry 获取条目
func (s *EntrySet) GetEntry(path, method string) *Entry {
	for i := range s.Items {
		item := s.Items[i]
		if item.Path == path && item.Method == method {
			return item
		}
	}

	return nil
}

//UniquePathEntry GetEntry 获取条目
func (s *EntrySet) UniquePathEntry() []*Entry {
	var items []*Entry
	for i := range s.Items {
		item := s.Items[i]
		newObj := item.Copy()
		newObj.Path = item.UniquePath()
		items = append(items, newObj)
	}

	return items
}
