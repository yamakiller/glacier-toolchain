package protobuf

import (
	"fmt"
	"os"
	"os/exec"

	"github.com/spf13/cobra"
)

// InitCmd 初始化系统
var installCmd = &cobra.Command{
	Use:   "install",
	Short: "安装项目依赖的protobuf文件",
	Long:  `安装项目依赖的protobuf文件`,
	RunE: func(cmd *cobra.Command, args []string) error {

		execRun := exec.Command("go", "install", "google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest")
		if out, err := execRun.CombinedOutput(); err != nil {
			fmt.Fprintf(os.Stderr, "%s-error:%v\n", string(out), err)
			return err
		}

		execRun = exec.Command("go", "install", "github.com/favadi/protoc-go-inject-tag@latest")
		if out, err := execRun.CombinedOutput(); err != nil {
			fmt.Fprintf(os.Stderr, "%s-error:%v\n", string(out), err)
			return err
		}
		return nil
	},
}

func init() {
	Cmd.AddCommand(installCmd)
}
