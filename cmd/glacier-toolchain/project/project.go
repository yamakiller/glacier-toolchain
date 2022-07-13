package project

import (
	"bytes"
	"embed"
	"fmt"
	"github.com/pkg/errors"
	"github.com/yamakiller/glacier-toolchain/tools/cli"
	"go/format"
	"io/fs"
	"io/ioutil"
	"os"
	"path"
	"path/filepath"
	"strings"
	"text/template"

	"github.com/AlecAivazis/survey/v2"
	"gopkg.in/yaml.v3"
)

//go:embed templates/*
var templates embed.FS

const ProjectSettingFilePath = ".toolchain.yaml"

// LoadConfigFromCLI 配置
func LoadConfigFromCLI() (*Project, error) {
	p := &Project{
		render:     template.New("project"),
		createdDir: map[string]bool{},
	}

	p.render.Funcs(p.FuncMap())

	err := survey.AskOne(
		&survey.Input{
			Message: "请输入项目包名称:",
			Default: "gitee.com/go-course/glacier-toolchain-demo",
		},
		&p.PKG,
		survey.WithValidator(survey.Required),
	)
	if err != nil {
		return nil, err
	}

	err = survey.AskOne(
		&survey.Input{
			Message: "请输入项目描述:",
			Default: "",
		},
		&p.Description,
		survey.WithValidator(survey.Required),
	)
	if err != nil {
		return nil, err
	}

	// 选择是否接入权限中心
	enableGlacierAuth := &survey.Confirm{
		Message: "是否接入权限中心[glacier auth]",
	}
	err = survey.AskOne(enableGlacierAuth, &p.EnableGlacierAuth)
	if err != nil {
		return nil, err
	}

	if p.EnableGlacierAuth {
		p.LoadGlacierAuthConfig()
	}

	// 选择使用的存储
	choicedDB := ""
	choiceDB := &survey.Select{
		Message: "选择数据库类型:",
		Options: []string{"MySQL", "PostgreSQL", "MongoDB"},
		Default: "MySQL",
	}
	err = survey.AskOne(choiceDB, &choicedDB)
	if err != nil {
		return nil, err
	}

	switch choicedDB {
	case "MySQL":
		p.EnableMySQL = true
		p.LoadMySQLConfig()
	case "PostgreSQL":
		p.EnablePostgreSQL = true
		p.LoadPostgreSQLConfig()
	case "MongoDB":
		p.EnableMongoDB = true
		p.LoadMongoDBConfig()
	}

	// 选择是否开启缓存
	enableCache := &survey.Confirm{
		Message: "是否开始缓存",
	}
	err = survey.AskOne(enableCache, &p.EnableCache)
	if err != nil {
		return nil, err
	}

	// 选择是否生成样例
	genExample := &survey.Confirm{
		Message: "生成样例代码",
	}
	survey.AskOne(genExample, &p.GenExample)

	if p.GenExample {
		// 选择使用的HTTP 框架
		choiceFW := &survey.Select{
			Message: "选择HTTP框架:",
			Options: []string{"go-restful", "gin", "httprouter"},
			Default: "go-restful",
		}
		err = survey.AskOne(choiceFW, &p.HttpFramework)
		if err != nil {
			return nil, err
		}
	}

	p.caculate()
	return p, nil
}

func LoadConfigFromYAMLCLI() (*Project, error) {

	var PKG string
	err := survey.AskOne(
		&survey.Input{
			Message: "请输入项目包名称:",
			Default: "gitee.com/go-course/glacier-toolchain-demo",
		},
		&PKG,
		survey.WithValidator(survey.Required),
	)

	if err != nil {
		return nil, err
	}

	projectPath := path.Join(os.Getenv("GOPATH"), "src", PKG, ProjectSettingFilePath)
	if !isFileExists(projectPath) {
		return nil, fmt.Errorf("%s project file not exits", projectPath)
	}

	return loadProjectFromYAML(projectPath)
}

func loadProjectFromYAML(path string) (*Project, error) {
	fp, err := os.Open(path)
	if err != nil {
		return nil, err
	}
	defer func(fp *os.File) {
		err := fp.Close()
		if err != nil {

		}
	}(fp)

	p := &Project{}
	err = yaml.NewDecoder(fp).Decode(p)
	if err != nil {
		return nil, err
	}

	return p, nil
}

func isFileExists(path string) bool {
	_, err := os.Stat(path) //os.Stat获取文件信息
	if err != nil {
		if os.IsExist(err) {
			return true
		}
		return false
	}
	return true
}

type Project struct {
	PKG               string       `yaml:"pkg"`
	Name              string       `yaml:"name"`
	Description       string       `yaml:"description"`
	EnableGlacierAuth bool         `yaml:"enable_glacier_auth"`
	GlacierAuth       *GlacierAuth `yaml:"-"`
	EnableMySQL       bool         `yaml:"enable_mysql"`
	MySQL             *MySQL       `yaml:"-"`
	EnablePostgreSQL  bool         `yaml:"enable_postgre_sql"`
	PostgreSQL        *PostgreSQL  `yaml:"_"`
	EnableMongoDB     bool         `yaml:"enable_mongodb"`
	MongoDB           *MongoDB     `yaml:"-"`
	GenExample        bool         `yaml:"gen_example"`
	HttpFramework     string       `yaml:"http_framework"`
	EnableCache       bool         `yaml:"enable_cache"`

	render     *template.Template
	createdDir map[string]bool
}

type ProjectAdd struct {
	PKG               string       `yaml:"pkg"`
	AppName           string       `yaml:"-"`
	Name              string       `yaml:"name"`
	Description       string       `yaml:"description"`
	EnableGlacierAuth bool         `yaml:"enable_glacier_auth"`
	GlacierAuth       *GlacierAuth `yaml:"-"`
	EnableMySQL       bool         `yaml:"enable_mysql"`
	MySQL             *MySQL       `yaml:"-"`
	EnablePostgreSQL  bool         `yaml:"enable_postgre_sql"`
	PostgreSQL        *PostgreSQL  `yaml:"_"`
	EnableMongoDB     bool         `yaml:"enable_mongodb"`
	MongoDB           *MongoDB     `yaml:"-"`
	GenExample        bool         `yaml:"gen_example"`
	HttpFramework     string       `yaml:"http_framework"`
	EnableCache       bool         `yaml:"enable_cache"`

	render     *template.Template
	createdDir map[string]bool
}

// GlacierAuth 鉴权服务配置
type GlacierAuth struct {
	Host         string
	Port         string
	ClientID     string
	ClientSecret string
}

type MySQL struct {
	Host     string
	Port     string
	Database string
	UserName string
	Password string
}

type PostgreSQL struct {
	Host     string
	Port     string
	Database string
	UserName string
	Password string
}

type MongoDB struct {
	Endpoints []string
	UserName  string
	Password  string
	Database  string
	AuthDB    string
}

// Init 初始化项目
func (p *Project) Init() error {
	fn := func(path string, d fs.DirEntry, _ error) error {
		// 不处理目录
		if d.IsDir() {
			return nil
		}

		// 处理是否生成样例代码
		if p.GenExample {
			if strings.Contains(path, "apps/example") {
				// 只生成对应框架的样例代码
				if strings.Contains(path, "apps/example/api") && p.HttpFramework != "" {
					if !strings.HasSuffix(path, fmt.Sprintf(".%s.tpl", p.HttpFramework)) {
						return nil
					}
				}
			}
			if strings.Contains(path, "protocol/http.go") && p.HttpFramework != "" {
				if !strings.HasSuffix(path, fmt.Sprintf(".%s.tpl", p.HttpFramework)) {
					return nil
				}
			}
		} else {
			return nil
		}

		// 如果不是使用MySQL,PostgreSQL, 不需要渲染的文件
		if strings.Contains(path, "apps/example/impl/sql") && !(p.EnableMySQL || p.EnablePostgreSQL) {
			return nil
		}

		// 忽略不是模板的文件
		if !strings.HasSuffix(d.Name(), ".tpl") {
			return nil
		}

		// 读取模板内容
		data, err := templates.ReadFile(path)
		if err != nil {
			return err
		}

		// 替换templates为项目目录名称
		target := strings.Replace(path, "templates", p.Name, 1)
		dirName := filepath.Dir(target)

		// 去除模版后缀
		sourceFileName := strings.TrimSuffix(filepath.Base(target), ".tpl")
		if p.HttpFramework != "" {
			// 去除框架后缀
			sourceFileName = strings.TrimSuffix(sourceFileName, "."+p.HttpFramework)
		}

		return p.rendTemplate(dirName, sourceFileName, string(data))
	}

	err := fs.WalkDir(templates, "templates", fn)
	if err != nil {
		return err
	}

	// 保存项目设置文件
	err = p.SaveFile(path.Join(p.Name, ProjectSettingFilePath))
	if err != nil {
		fmt.Printf("保存项目配置文件: %s 失败: %s\n", ProjectSettingFilePath, err)
	}

	fmt.Println("项目初始化完成, 项目结构如下: ")
	if err := p.show(); err != nil {
		return err
	}

	return nil
}

func (p *Project) Add() error {
	var AppName string
	err := survey.AskOne(
		&survey.Input{
			Message: "请输入应用名:",
			Default: "example",
		},
		&AppName,
		survey.WithValidator(survey.Required),
	)

	if err != nil {
		return err
	}

	return nil
}

func (p *Project) show() error {
	return cli.Tree(os.Stdout, p.Name, true)
}

func (p *Project) caculate() {
	if p.PKG != "" {
		slice := strings.Split(p.PKG, "/")
		p.Name = slice[len(slice)-1]
	}
}

func (p *Project) ToYAML() (string, error) {
	b, err := yaml.Marshal(p)
	if err != nil {
		return "", err
	}

	return string(b), nil
}

func (p *Project) SaveFile(filePath string) error {
	f, err := os.Create(filePath)
	if err != nil {
		return err
	}
	defer func(f *os.File) {
		err := f.Close()
		if err != nil {

		}
	}(f)

	content, err := p.ToYAML()
	if err != nil {
		return err
	}

	_, err = f.WriteString(content)
	return err
}

func (p *Project) dirNotExist(path string) bool {
	if _, ok := p.createdDir[path]; ok {
		return false
	}

	return true
}

func (p *Project) rendTemplate(dir, file, tmpl string) error {
	if dir != "" {
		if p.dirNotExist(dir) {
			err := os.MkdirAll(dir, os.ModePerm)
			if err != nil {
				return err
			}
			p.createdDir[dir] = true
		}
	}

	filePath := ""
	if dir != "" {
		filePath = dir + "/" + file
	} else {
		filePath = file
	}

	t, err := p.render.Parse(tmpl)
	if err != nil {
		return fmt.Errorf("render %s/%s error, %s", dir, file, err)
	}

	buf := bytes.NewBufferString("")
	err = t.Execute(buf, p)
	if err != nil {
		return errors.Wrapf(err, "template data err")
	}

	var content []byte
	if path.Ext(file) == "go" {
		code, err := format.Source(buf.Bytes())
		if err != nil {
			return errors.Wrapf(err, "format %s code err", file)
		}
		content = code
	} else {
		content = buf.Bytes()
	}

	return ioutil.WriteFile(filePath, content, 0644)
}

func (p *Project) FuncMap() template.FuncMap {
	return template.FuncMap{
		// []string ==> ["xxx", "xxx"]
		"ListToTOML": func(strs []string) string {
			var strList []string
			for i := range strs {
				strList = append(strList, fmt.Sprintf(`"%s"`, strs[i]))
			}
			return "[" + strings.Join(strList, ",") + "]"
		},
	}

}
