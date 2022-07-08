package resource

import (
	"bytes"
	"fmt"
	"strings"
)

// ParseVisiableModeFromString Parse VisiableMode from string
func ParseVisiableModeFromString(str string) (VisiableMode, error) {
	key := strings.Trim(string(str), `"`)
	v, ok := VisiableMode_value[strings.ToUpper(key)]
	if !ok {
		return 0, fmt.Errorf("unknown VisiableMode: %s", str)
	}

	return VisiableMode(v), nil
}

// Equal type compare
func (x VisiableMode) Equal(target VisiableMode) bool {
	return x == target
}

// IsIn todo
func (x VisiableMode) IsIn(targets ...VisiableMode) bool {
	for _, target := range targets {
		if x.Equal(target) {
			return true
		}
	}

	return false
}

// MarshalJSON todo
func (x VisiableMode) MarshalJSON() ([]byte, error) {
	b := bytes.NewBufferString(`"`)
	b.WriteString(strings.ToUpper(x.String()))
	b.WriteString(`"`)
	return b.Bytes(), nil
}

// UnmarshalJSON todo
func (x *VisiableMode) UnmarshalJSON(b []byte) error {
	ins, err := ParseVisiableModeFromString(string(b))
	if err != nil {
		return err
	}
	*x = ins
	return nil
}
