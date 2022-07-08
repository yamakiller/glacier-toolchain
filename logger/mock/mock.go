package mock

import "bytes"

// NewStandardLogger todo
func NewStandardLogger() *StandardLogger {
	return &StandardLogger{
		Buffer: bytes.NewBuffer([]byte{}),
	}
}

// StandardLogger 用于单元测试
type StandardLogger struct {
	Buffer *bytes.Buffer
}

// Debug ...
func (l *StandardLogger) Debug(msgs ...interface{}) {
	for _, m := range msgs {
		l.Buffer.Write([]byte(m.(string)))
	}
}

// Info ...
func (l *StandardLogger) Info(msgs ...interface{}) {

}

// Warn ...
func (l *StandardLogger) Warn(msgs ...interface{}) {

}

// Error ...
func (l *StandardLogger) Error(msgs ...interface{}) {

}

// Fatal ...
func (l *StandardLogger) Fatal(msgs ...interface{}) {

}

// Panic ...
func (l *StandardLogger) Panic(msgs ...interface{}) {

}
