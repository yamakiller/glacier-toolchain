package request

import (
	"bytes"
	"fmt"
	"strings"
)

// ParseUpdateModeFromString Parse UpdateMode from string
func ParseUpdateModeFromString(str string) (UpdateMode, error) {
	key := strings.Trim(string(str), `"`)
	v, ok := UpdateMode_value[strings.ToUpper(key)]
	if !ok {
		return 0, fmt.Errorf("unknown UpdateMode: %s", str)
	}

	return UpdateMode(v), nil
}

// Equal type compare
func (x UpdateMode) Equal(target UpdateMode) bool {
	return x == target
}

// IsIn todo
func (x UpdateMode) IsIn(targets ...UpdateMode) bool {
	for _, target := range targets {
		if x.Equal(target) {
			return true
		}
	}

	return false
}

// MarshalJSON todo
func (x UpdateMode) MarshalJSON() ([]byte, error) {
	b := bytes.NewBufferString(`"`)
	b.WriteString(strings.ToUpper(x.String()))
	b.WriteString(`"`)
	return b.Bytes(), nil
}

// UnmarshalJSON todo
func (x *UpdateMode) UnmarshalJSON(b []byte) error {
	ins, err := ParseUpdateModeFromString(string(b))
	if err != nil {
		return err
	}
	*x = ins
	return nil
}
