package lable

import "github.com/yamakiller/glacier-toolchain/pb/http"

const (
	// Action key name
	Action = "action"
)

var (
	// Get Label
	Get = action("get")
	// List label
	List = action("list")
	// Create label
	Create = action("create")
	// Update label
	Update = action("update")
	// Delete label
	Delete = action("delete")
)

//NewActionLabel 实例一个动作标签
func NewActionLabel(name string) *http.Label {
	return action(name)
}

func action(value string) *http.Label {
	return http.NewLable(Action, value)
}
