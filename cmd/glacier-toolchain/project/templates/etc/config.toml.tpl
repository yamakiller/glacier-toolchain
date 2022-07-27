[app]
name = "{{.Name}}"
key  = "this is your app key"

[app.http]
host = "127.0.0.1"
port = "8050"

[app.grpc]
host = "127.0.0.1"
port = "18050"
{{if $.EnableCache}}
[cache]
    type = "{{.CacheType}}"
{{ if $.EnableRedis }}
[cache.redis]
prefix = "{{.Redis.Prefix}}"
address = "{{.Redis.Address}}"
db = {{.Redis.DB}}
password = "{{.Redis.Password}}"
default_ttl = {{.Redis.DefaultTTL}}
{{- end}}
{{ if $.EnableMemory }}
[cache.memory]
ttl = {{.Memory.TTL}}
size = {{.Memory.Size}}
{{- end}}
{{- end}}


{{ if $.EnablePostgreSQL }}
[postgresql]
host = "{{.PostgreSQL.Host}}"
port = "{{.PostgreSQL.Port}}"
client_id = "{{.PostgreSQL.ClientID}}"
client_secret = "{{.PostgreSQL.ClientSecret}}"
{{- end }}

{{ if $.EnableMySQL }}
[mysql]
host = "{{.MySQL.Host}}"
port = "{{.MySQL.Port}}"
database = "{{.MySQL.Database}}"
username = "{{.MySQL.UserName}}"
password = "{{.MySQL.Password}}"
{{- end }}

{{ if $.EnableMongoDB }}
[mongodb]
endpoints = {{.MongoDB.Endpoints | ListToTOML}}
username = "{{.MongoDB.UserName}}"
password = "{{.MongoDB.Password}}"
database = "{{.MongoDB.Database}}"
{{- end }}

[log]
level = "debug"
path = "logs"
format = "text"
to = "stdout"