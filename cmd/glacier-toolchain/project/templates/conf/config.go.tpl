package conf

import (
	"context"
	"sync"
	"fmt"
	"time"

{{ if $.EnableMySQL -}}
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
{{- end }}
{{ if $.EnablePostgreSQL -}}
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
{{- end }}
{{ if $.EnableGlacierAuth -}}
	gac "github.com/yamakiller/glacier-auth/client"
{{- end }}
{{ if $.EnableCache -}}
	"github.com/yamakiller/glacier-toolchain/cache/memory"
	"github.com/yamakiller/glacier-toolchain/cache/redis"
{{- end }}
{{ if $.EnableMongoDB -}}
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
{{- end }}
)

var (
{{ if $.EnableMySQL -}}
	db *gorm.DB
{{- end }}
{{ if $.EnablePostgreSQL -}}
    db *gorm.DB
{{- end }}
{{ if $.EnableMongoDB -}}
	mongoClient *mongo.Client
{{- end }}
)

func newConfig() *Config {
	return &Config{
		App:     newDefaultAPP(),
		Log:     newDefaultLog(),
{{ if $.EnableMySQL -}}
		MySQL:   newDefaultMySQL(),
{{- end }}
{{ if $.EnablePostgreSQL -}}
		PostgreSQL:: newDefaultPostgreSQL(),
{{- end }}
{{ if $.EnableMongoDB -}}
		Mongo:   newDefaultMongoDB(),
{{- end }}
{{ if $.EnableGlacierAuth -}}
		GlacierAuth: newDefaultGlacierAuth(),
{{- end }}
{{ if $.EnableCache -}}
		Cache:   newDefaultCache(),
{{- end }}
	}
}

// Config 应用配置
type Config struct {
	App   *app   `toml:"app"`
	Log   *log   `toml:"log"`
{{ if $.EnableMySQL -}}
	MySQL *mysql `toml:"mysql"`
{{- end }}
{{ if $.EnablePostgreSQL -}}
    PostgreSQL *postgresql `toml:"postgresql"`
{{- end }}
{{ if $.EnableMongoDB -}}
	Mongo *mongodb `toml:"mongodb"`
{{- end }}
{{ if $.EnableGlacierAuth -}}
	GlacierAuth  *glacierAuth  `toml:"glacier-auth"`
{{- end }}
{{ if $.EnableCache -}}
	Cache *_cache  `toml:"cache"`
{{- end }}
}

type app struct {
	Name       string `toml:"name" env:"APP_NAME"`
	EncryptKey string `toml:"encrypt_key" env:"APP_ENCRYPT_KEY"`
	HTTP       *http  `toml:"http"`
	GRPC       *grpc  `toml:"grpc"`
}

func newDefaultAPP() *app {
	return &app{
		Name:       "cmdb",
		EncryptKey: "default app encrypt key",
		HTTP:       newDefaultHTTP(),
		GRPC:       newDefaultGRPC(),
	}
}

type http struct {
	Host      string `toml:"host" env:"HTTP_HOST"`
	Port      string `toml:"port" env:"HTTP_PORT"`
	EnableSSL bool   `toml:"enable_ssl" env:"HTTP_ENABLE_SSL"`
	CertFile  string `toml:"cert_file" env:"HTTP_CERT_FILE"`
	KeyFile   string `toml:"key_file" env:"HTTP_KEY_FILE"`
}

func (a *http) Addr() string {
	return a.Host + ":" + a.Port
}

func newDefaultHTTP() *http {
	return &http{
		Host: "127.0.0.1",
		Port: "8050",
	}
}

type grpc struct {
	Host      string `toml:"host" env:"GRPC_HOST"`
	Port      string `toml:"port" env:"GRPC_PORT"`
	EnableSSL bool   `toml:"enable_ssl" env:"GRPC_ENABLE_SSL"`
	CertFile  string `toml:"cert_file" env:"GRPC_CERT_FILE"`
	KeyFile   string `toml:"key_file" env:"GRPC_KEY_FILE"`
}

func (a *grpc) Addr() string {
	return a.Host + ":" + a.Port
}

func newDefaultGRPC() *grpc {
	return &grpc{
		Host: "127.0.0.1",
		Port: "18050",
	}
}

type log struct {
	Level   string    `toml:"level" env:"LOG_LEVEL"`
	PathDir string    `toml:"path_dir" env:"LOG_PATH_DIR"`
	Format  LogFormat `toml:"format" env:"LOG_FORMAT"`
	To      LogTo     `toml:"to" env:"LOG_TO"`
}

func newDefaultLog() *log {
	return &log{
		Level:   "debug",
		PathDir: "logs",
		Format:  "text",
		To:      "stdout",
	}
}

{{ if $.EnableGlacierAuth -}}
// Auth auth 配置
type glacierAuth struct {
	Host      string `toml:"host" env:"GLACIERAUTH_HOST"`
	Port      string `toml:"port" env:"GLACIERAUTH_PORT"`
	ClientID string `toml:"client_id" env:"GLACIERAUTH_CLIENT_ID"`
	ClientSecret string `toml:"client_secret" env:"GLACIERAUTH_CLIENT_SECRET"`
}

func (a *glacierAuth) Addr() string {
	return a.Host + ":" + a.Port
}

func (a *glacierAuth) Client() (*gac.Client, error) {
	if gac.C() == nil {
		conf := gac.NewDefaultConfig()
		conf.SetAddress(a.Addr())
		conf.SetClientCredentials(a.ClientID, a.ClientSecret)
		client, err := gac.NewClient(conf)
		if err != nil {
			return nil, err
		}
		gac.SetGlobal(client)
	}

	return gac.C(), nil
}

func newDefaultGlacierAuth() *glacierAuth {
	return &glacierAuth{}
}
{{- end }}

{{ if $.EnableMongoDB -}}
func newDefaultMongoDB() *mongodb {
	return &mongodb{
		Database:  "",
		Endpoints: []string{"127.0.0.1:27017"},
	}
}

type mongodb struct {
	Endpoints []string `toml:"endpoints" env:"MONGO_ENDPOINTS" envSeparator:","`
	UserName  string   `toml:"username" env:"MONGO_USERNAME"`
	Password  string   `toml:"password" env:"MONGO_PASSWORD"`
	Database  string   `toml:"database" env:"MONGO_DATABASE"`
	lock      sync.Mutex
}

// Client 获取一个全局的mongodb客户端连接
func (m *mongodb) Client() (*mongo.Client, error) {
	// 加载全局数据量单例
	m.lock.Lock()
	defer m.lock.Unlock()
	if mongoClient == nil {
		conn, err := m.getClient()
		if err != nil {
			return nil, err
		}
		mongoClient = conn
	}

	return mongoClient, nil
}

func (m *mongodb) GetDB() (*mongo.Database, error) {
	conn, err := m.Client()
	if err != nil {
		return nil, err
	}
	return conn.Database(m.Database), nil
}

func (m *mongodb) getClient() (*mongo.Client, error) {
	opts := options.Client()
	cred := options.Credential{
		AuthSource: m.Database,
	}

	if m.UserName != "" && m.Password != "" {
		cred.Username = m.UserName
		cred.Password = m.Password
		cred.PasswordSet = true
		opts.SetAuth(cred)
	}
	opts.SetHosts(m.Endpoints)
	opts.SetConnectTimeout(5 * time.Second)

	// Connect to MongoDB
	client, err := mongo.Connect(context.TODO(), opts)
	if err != nil {
		return nil, fmt.Errorf("new mongodb client error, %s", err)
	}

	if err = client.Ping(context.TODO(), nil); err != nil {
		return nil, fmt.Errorf("ping mongodb server(%s) error, %s", m.Endpoints, err)
	}

	return client, nil
}
{{- end }}

{{ if $.EnableMySQL -}}
type mysql struct {
	Host        string `toml:"host" env:"MYSQL_HOST"`
	Port        string `toml:"port" env:"MYSQL_PORT"`
	UserName    string `toml:"username" env:"MYSQL_USERNAME"`
	Password    string `toml:"password" env:"MYSQL_PASSWORD"`
	Database    string `toml:"database" env:"MYSQL_DATABASE"`
	MaxOpenConn int    `toml:"max_open_conn" env:"MYSQL_MAX_OPEN_CONN"`
	MaxIdleConn int    `toml:"max_idle_conn" env:"MYSQL_MAX_IDLE_CONN"`
	MaxLifeTime int    `toml:"max_life_time" env:"MYSQL_MAX_LIFE_TIME"`
	MaxIdleTime int    `toml:"max_idle_time" env:"MYSQL_MAX_IDLE_TIME"`
	lock        sync.Mutex
}

func newDefaultMySQL() *mysql {
	return &mysql{
		Database:    "{{.Name}}",
		Host:        "127.0.0.1",
		Port:        "3306",
		MaxOpenConn: 200,
		MaxIdleConn: 100,
	}
}

// getDBConn use to get db connection pool
func (m *mysql) getDBConn() (*gorm.DB, error) {
	var err error
	dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?charset=utf8&multiStatements=true",
	                   m.UserName, m.Password, m.Host, m.Port, m.Database)
	db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{})
	if err != nil {
		return nil, fmt.Errorf("connect to mysql<%s> error, %s", dsn, err.Error())
	}

	sqlDb := db.DB()
	sqlDb.SetMaxOpenConns(m.MaxOpenConn)
	sqlDb.SetMaxIdleConns(m.MaxIdleConn)
	if m.MaxLifeTime != 0 {
		sqlDb.SetConnMaxLifetime(time.Second * time.Duration(m.MaxLifeTime))
	}
	if m.MaxIdleConn != 0 {
		sqlDb.SetConnMaxIdleTime(time.Second * time.Duration(m.MaxIdleTime))
	}

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	if err := sqlDb.PingContext(ctx); err != nil {
		return nil, fmt.Errorf("ping mysql<%s> error, %s", dsn, err.Error())
	}
	return db, nil
}
func (m *mysql) GetDB() (*gorm.DB, error) {
	// 加载全局数据量单例
	m.lock.Lock()
	defer m.lock.Unlock()
	if db == nil {
		conn, err := m.getDBConn()
		if err != nil {
			return nil, err
		}
		db = conn
	}
	return db, nil
}
{{- end }}
{{ if $.EnablePostgreSQL -}}
type postgresql struct {
	Host        string `toml:"host" env:"POSTGRE_HOST"`
	Port        string `toml:"port" env:"POSTGRE_PORT"`
	UserName    string `toml:"username" env:"POSTGRE_USERNAME"`
	Password    string `toml:"password" env:"POSTGRE_PASSWORD"`
	Database    string `toml:"database" env:"POSTGRE_DATABASE"`
	MaxOpenConn int    `toml:"max_open_conn" env:"POSTGRE_MAX_OPEN_CONN"`
	MaxIdleConn int    `toml:"max_idle_conn" env:"POSTGRE_MAX_IDLE_CONN"`
	MaxLifeTime int    `toml:"max_life_time" env:"POSTGRE_MAX_LIFE_TIME"`
	MaxIdleTime int    `toml:"max_idle_time" env:"POSTGRE_MAX_IDLE_TIME"`
	lock        sync.Mutex
}
func newDefaultPostgreSQL() *postgresql {
	return &postgresql{
		Database:    "{{.Name}}",
		Host:        "127.0.0.1",
		Port:        "9902",
		MaxOpenConn: 200,
		MaxIdleConn: 100,
	}
}
// getDBConn use to get db connection pool
func (m *postgresql) getDBConn() (*gorm.DB, error) {
    var err error
    dsn := fmt.Sprintf("user=%s password=%s host=%s port=%s dbname=%s sslmode=disable TimeZone=Asia/Shanghai",
                        m.UserName, m.Password, m.Host, m.Port, m.Database)
    db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
    if err != nil {
        return nil, fmt.Errorf("connect to PostgreSQL<%s> error, %s", dsn, err.Error())
    }

    sqlDb := db.DB()
    sqlDb.SetMaxOpenConns(m.MaxOpenConn)
    sqlDb.SetMaxIdleConns(m.MaxIdleConn)
    if m.MaxLifeTime != 0 {
        sqlDb.SetConnMaxLifetime(time.Second * time.Duration(m.MaxLifeTime))
    }
    if m.MaxIdleConn != 0 {
        sqlDb.SetConnMaxIdleTime(time.Second * time.Duration(m.MaxIdleTime))
    }

    ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
    defer cancel()
    if err := sqlDb.PingContext(ctx); err != nil {
        return nil, fmt.Errorf("ping PostgreSQL<%s> error, %s", dsn, err.Error())
    }
    return db, nil
}
func (m *postgresql) GetDB() (*gorm.DB, error) {
	// 加载全局数据量单例
	m.lock.Lock()
	defer m.lock.Unlock()
	if db == nil {
		conn, err := m.getDBConn()
		if err != nil {
			return nil, err
		}
		db = conn
	}
	return db, nil
}
{{- end }}

{{ if $.EnableCache -}}
func newDefaultCache() *_cache {
	return &_cache{
		Type:   "memory",
		Memory: memory.NewDefaultConfig(),
		Redis:  redis.NewDefaultConfig(),
	}
}

type _cache struct {
	Type   string         `toml:"type" json:"type" yaml:"type" env:"CACHE_TYPE"`
	Memory *memory.Config `toml:"memory" json:"memory" yaml:"memory"`
	Redis  *redis.Config  `toml:"redis" json:"redis" yaml:"redis"`
}
{{- end }}