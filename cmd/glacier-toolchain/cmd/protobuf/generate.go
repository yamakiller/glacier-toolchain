package protobuf

import (
	"fmt"
	"github.com/spf13/cobra"
	"os"
	"os/exec"
	"path"
	"path/filepath"
	"strings"
)

// InitCmd 初始化系统
var generateCmd = &cobra.Command{
	Use:   "generate",
	Short: "构建指proto文件",
	Long:  `构建指proto文件,指令:glacier-toolchain proto generate [proto bin] [proto include] [file path]`,
	RunE: func(cmd *cobra.Command, args []string) error {
		if len(args) == 0 {
			return fmt.Errorf("input file is mandatory, see: -help")
		}

		var (
			bin     string
			include string
			pkg     string
			err     error
		)
		bin, err = cmd.Flags().GetString("bin")
		if err != nil {
			return err
		}
		include, err = cmd.Flags().GetString("include")
		if err != nil {
			return err
		}

		pkg, err = cmd.Flags().GetString("pkg")
		if err != nil {
			return err
		}

		if pkg != "" {

		}

		var matchedFiles []string
		for _, v := range args {
			files, err := filepath.Glob(v)
			if err != nil {
				return err
			}
			// 只匹配Proto源码文件
			if strings.HasSuffix(v, ".proto") {
				matchedFiles = append(matchedFiles, files...)
			}
		}

		if len(matchedFiles) == 0 {
			return fmt.Errorf("no file matched")
		}
		for _, filePath := range matchedFiles {
			execRun := exec.Command(bin,
				"--proto_path=.",
				fmt.Sprintf("--proto_path=%s", include),
				fmt.Sprintf("--proto_path=%s", strings.Replace(path.Join(os.Getenv("GOPATH"), "src"), "\\", "/", -1)),
				"--go_out=.",
				fmt.Sprintf("--go_opt=module=%s", pkg),
				"--go-grpc_out=.",
				fmt.Sprintf("--go-grpc_opt=module=%s", pkg),
				strings.Replace(filePath, "\\", "/", -1))

			if out, err := execRun.CombinedOutput(); err != nil {
				fmt.Fprintf(os.Stderr, "%s-error:%v\n", string(out), err)
				return err
			}
		}

		return nil
	},
}

func init() {
	generateCmd.Flags().StringP("bin", "", "", "proto bin path")
	generateCmd.Flags().StringP("include", "", "", "proto include path")
	generateCmd.Flags().StringP("pkg", "", "", "project package golang")
	generateCmd.MarkFlagRequired("bin")
	generateCmd.MarkFlagRequired("include")
	generateCmd.MarkFlagRequired("pkg")

	Cmd.AddCommand(generateCmd)
}
