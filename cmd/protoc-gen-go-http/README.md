# protoc-gen-go-http
1.工具箱 grpc http 代码生成器, 根据rpc 扩展自动生成REST API  
2.使用说明:
>>protoc-gen-go-http -version 查看工具版本信息  
>>protoc-gen-go-http -require_unimplemented_servers 设置为false以匹配旧服务.  
>>protoc-gen-go-http  
>>>>-i: Input file(s); proto definitions, either as text or pre-compiled binary (via protoc)  
>>>>-o: Output file; if none specified, writes to stdout  
>>>>-t: Template to use; defaults to csharp  
>>>>-p: Property for the template; value defaults to true; use -p:help to view available options  
>>>>-q: Quiet; suppresses header  
>>>>-d: Include all dependencies of the input files in the set so the set is self-contained.  
>>>>-ns: Default namespace; used in code generation when no package is specified  