[app]
name = "{{.Name}}"
key  = "this is your app key"

[app.http]
host = "127.0.0.1"
port = "8050"

[app.grpc]
host = "127.0.0.1"
port = "18050"

{{ if $.EnableGlacierAuth }}
[glacierauth]
host = "{{.GlacierAuth.Host}}"
port = "{{.GlacierAuth.Port}}"
client_id = "{{.GlacierAuth.ClientID}}"
client_secret = "{{.GlacierAuth.ClientSecret}}"
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