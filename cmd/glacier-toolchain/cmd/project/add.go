package project

import (
	"fmt"
	"github.com/AlecAivazis/survey/v2/terminal"
	"github.com/spf13/cobra"
	"github.com/yamakiller/glacier-toolchain/cmd/glacier-toolchain/project"
)

// addCmd 初始化系统
var addCmd = &cobra.Command{
	Use:   "add",
	Short: "增加应用",
	Long:  `增加一个glacier-toolchain项目的应用`,
	RunE: func(cmd *cobra.Command, args []string) error {

		p, err := project.LoadConfigFromYAMLCLI()
		if err != nil {
			if err == terminal.InterruptErr {
				fmt.Println("项目初始化取消")
				return nil
			}
			return err
		}

		err = p.Add()
		if err != nil {
			return err
		}
		return nil
	},
}

func init() {
	Cmd.AddCommand(addCmd)
}
