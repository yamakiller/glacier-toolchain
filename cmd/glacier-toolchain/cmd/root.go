package cmd

import (
	"fmt"
	"github.com/spf13/cobra"
	"github.com/yamakiller/glacier-toolchain/cmd/glacier-toolchain/cmd/generate"
	"github.com/yamakiller/glacier-toolchain/cmd/glacier-toolchain/cmd/project"
	"github.com/yamakiller/glacier-toolchain/cmd/glacier-toolchain/cmd/protobuf"
	"os"
)

var verse bool

// RootCmd represents the base command when called without any subcommands
var RootCmd = &cobra.Command{
	Use:   "glacier-toolchain",
	Short: "glacier-toolchain 分布式服务构建工具",
	Long:  `glacier-toolchain 分布式服务构建工具`,
	RunE: func(cmd *cobra.Command, args []string) error {
		return cmd.Help()
	},
}

// Execute adds all child commands to the root command sets flags appropriately.
// This is called by main.main(). It only needs to happen once to the rootCmd.
func Execute() {
	if err := RootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(-1)
	}
}

func init() {
	RootCmd.AddCommand(project.Cmd, generate.Cmd, protobuf.Cmd)
	RootCmd.PersistentFlags().BoolVarP(&verse, "version", "v", false, "the glacier toolchain version")
}
