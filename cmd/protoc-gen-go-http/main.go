package main

import (
	"flag"
	"fmt"
	"github.com/yamakiller/glacier-toolchain/cmd/protoc-gen-go-http/generater"
	"google.golang.org/protobuf/compiler/protogen"
	"google.golang.org/protobuf/types/pluginpb"
)

const version = "0.1.0"

var _ *bool

func main() {
	showVersion := flag.Bool("version",
		false,
		"print the version and exit")

	flag.Parse()
	if *showVersion {
		fmt.Printf("protoc-gen-go-http %v\n", version)
		return
	}

	var flags flag.FlagSet
	_ = flags.Bool("require_unimplemented_servers", true, "set to false to match legacy behavior")

	protogen.Options{
		ParamFunc: flags.Set,
	}.Run(func(gen *protogen.Plugin) error {
		gen.SupportedFeatures = uint64(pluginpb.CodeGeneratorResponse_FEATURE_PROTO3_OPTIONAL)
		for _, f := range gen.Files {
			if !f.Generate {
				continue
			}

			g := generater.NewGenerator(gen, f)
			g.GenerateFile()
		}
		return nil
	})
}
