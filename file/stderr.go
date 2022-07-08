//go:build !windows
// +build !windows

package file

import "os"

// RedirectStandardError causes all standard error output to be directed to the
// given file.
func RedirectStandardError(toFile *os.File) error {
	return unix.Dup2(int(toFile.Fd()), 2)
}
