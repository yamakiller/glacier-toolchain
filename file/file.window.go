package file

import (
	"fmt"
	"golang.org/x/sys/windows"
	"os"
	"reflect"
	"strconv"
	"syscall"
	"unsafe"
)

type StateOS struct {
	IdxHi uint64 `json:"idxhi,"`
	IdxLo uint64 `json:"idxlo,"`
	Vol   uint64 `json:"vol,"`
}

var (
	modkernel32 = windows.NewLazySystemDLL("kernel32.dll")

	procGetFileInformationByHandleEx = modkernel32.NewProc("GetFileInformationByHandleEx")
)

// GetOSState returns the platform specific StateOS
func GetOSState(info os.FileInfo) StateOS {
	// os.SameFile must be called to populate the id fields. Otherwise, in case for example
	// os.Stat(file) is used to get the fileInfo, the ids are empty.
	// https://github.com/elastic/beats/filebeat/pull/53
	os.SameFile(info, info)

	// Gathering fileStat (which is fileInfo) through reflection as otherwise not accessible
	// See https://github.com/golang/go/blob/90c668d1afcb9a17ab9810bce9578eebade4db56/src/os/stat_windows.go#L33
	fileStat := reflect.ValueOf(info).Elem()

	// Get the three fields required to uniquely identify file und windows
	// More details can be found here: https://msdn.microsoft.com/en-us/library/aa363788(v=vs.85).aspx
	// Uint should already return uint64, but making sure this is the case
	// The required fields can be found here: https://github.com/golang/go/blob/master/src/os/types_windows.go#L78
	fileState := StateOS{
		IdxHi: fileStat.FieldByName("idxhi").Uint(),
		IdxLo: fileStat.FieldByName("idxlo").Uint(),
		Vol:   fileStat.FieldByName("vol").Uint(),
	}

	return fileState
}

// IsSame file checks if the files are identical
func (fs StateOS) IsSame(state StateOS) bool {
	return fs.IdxHi == state.IdxHi && fs.IdxLo == state.IdxLo && fs.Vol == state.Vol
}

func (fs StateOS) String() string {
	var buf [92]byte
	current := strconv.AppendUint(buf[:0], fs.IdxHi, 10)
	current = append(current, '-')
	current = strconv.AppendUint(current, fs.IdxLo, 10)
	current = append(current, '-')
	current = strconv.AppendUint(current, fs.Vol, 10)
	return string(current)
}

// ReadOpen opens a file for reading only
// As Windows blocks deleting a file when its open, some special params are passed here.
func ReadOpen(path string) (*os.File, error) {
	// Set all write flags
	// This indirectly calls syscall_windows::Open method https://github.com/golang/go/blob/7ebcf5eac7047b1eef2443eda1786672b5c70f51/src/syscall/syscall_windows.go#L251
	// As FILE_SHARE_DELETE cannot be passed to Open, os.CreateFile must be implemented directly

	// This is mostly the code from syscall_windows::Open. Only difference is passing the Delete flag
	// TODO: Open pull request to Golang so also Delete flag can be set
	if len(path) == 0 {
		return nil, fmt.Errorf("file '%s' not found. Error: %v", path, syscall.ERROR_FILE_NOT_FOUND)
	}

	pathp, err := syscall.UTF16PtrFromString(path)
	if err != nil {
		return nil, fmt.Errorf("error converting to UTF16: %v", err)
	}

	var access uint32
	access = syscall.GENERIC_READ

	shareholder := uint32(syscall.FILE_SHARE_READ | syscall.FILE_SHARE_WRITE | syscall.FILE_SHARE_DELETE)

	var sa *syscall.SecurityAttributes

	var createmode uint32

	createmode = syscall.OPEN_EXISTING

	handle, err := syscall.CreateFile(pathp,
		access,
		shareholder,
		sa,
		createmode,
		syscall.FILE_ATTRIBUTE_NORMAL,
		0)

	if err != nil {
		return nil, fmt.Errorf("error creating file '%s': %v", path, err)
	}

	return os.NewFile(uintptr(handle), path), nil
}

// IsRemoved checks wheter the file held by f is removed.
// On Windows IsRemoved reads the DeletePending flags using the GetFileInformationByHandleEx.
// A file is not removed/unlinked as long as at least one process still own a
// file handle. A delete file is only marked as deleted, and file attributes
// can still be read. Only opening a file marked with 'DeletePending' will
// fail.
func IsRemoved(f *os.File) bool {
	hdl := f.Fd()
	if hdl == uintptr(syscall.InvalidHandle) {
		return false
	}

	info := struct {
		AllocationSize int64
		EndOfFile      int64
		NumberOfLinks  int32
		DeletePending  bool
		Directory      bool
	}{}
	infoSz := unsafe.Sizeof(info)

	const class = 1 // FileStandardInfo
	r1, _, _ := syscall.Syscall6(
		procGetFileInformationByHandleEx.Addr(), 4, uintptr(hdl), class, uintptr(unsafe.Pointer(&info)), infoSz, 0, 0)
	if r1 == 0 {
		return true // assume file is removed if syscall errors
	}
	return info.DeletePending
}
