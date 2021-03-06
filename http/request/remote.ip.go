package request

import (
	"net/http"
	"strings"
)

var (
	// DefaultScanForwardHeaderKey 协商forward ip 的 handier key名称
	DefaultScanForwardHeaderKey = []string{"X-Forwarded-For", "X-Real-IP"}
)

func GetRemoteIP(r *http.Request) string {
	// 优先获取代理IP
	var ip string
	for _, key := range DefaultScanForwardHeaderKey {
		value := r.Header.Get(key)

		if strings.Contains(value, ", ") {
			i := strings.Index(value, ", ")
			if i == -1 {
				i = len(value)
			}

			ip = value[:i]
			break
		}

		if value != "" {
			ip = value
			break
		}
	}

	if ip != "" {
		return ip
	}

	// 如果没有获得代理IP则采用RemoteIP
	addr := strings.Split(r.RemoteAddr, ":")
	if len(addr) == 1 {
		return addr[0]
	}

	return strings.Join(addr[0:len(addr)-1], ":")
}
