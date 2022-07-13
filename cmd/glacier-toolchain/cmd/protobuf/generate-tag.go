package protobuf

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"github.com/spf13/cobra"
)

// InitCmd 初始化系统
var generatetagCmd = &cobra.Command{
	Use:   "generate-tag",
	Short: "对.pb.go 文件注入标签",
	Long:  `对.pb.go 文件注入标签,指令:glacier-toolchain proto generate-tag  [file path]`,
	RunE: func(cmd *cobra.Command, args []string) error {
		if len(args) == 0 {
			return fmt.Errorf("input file is mandatory, see: -help")
		}

		var matchedFiles []string
		for _, v := range args {
			files, err := filepath.Glob(v)
			if err != nil {
				return err
			}
			// 只匹配Proto源码文件
			if strings.HasSuffix(v, ".pb.go") {
				matchedFiles = append(matchedFiles, files...)
			}

		}
		for _, filePath := range matchedFiles {
			execRun := exec.Command("protoc-go-inject-tag",
				fmt.Sprintf("-input=%s", strings.Replace(filePath, "\\", "/", -1)),
			)
			if out, err := execRun.CombinedOutput(); err != nil {
				fmt.Fprintf(os.Stderr, "%s-error:%v\n", string(out), err)
				return err
			}
		}
		return nil
	},
}

func init() {
	Cmd.AddCommand(generatetagCmd)
}
