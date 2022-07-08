//go:build !windows
// +build !windows

package zap

import (
	"github.com/pkg/errors"
	"go.uber.org/zap/zapcore"
)

func newEventLog(_ string, _ zapcore.Encoder, _ zapcore.LevelEnabler) (zapcore.Core, error) {
	return nil, errors.New("event log is only supported on Windows")
}
