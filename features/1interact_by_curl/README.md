熟悉 es 的一些基本操作，linux 下使用 curl 命令来和 elasticsearch 交互，基本命令格式：

```bash
curl -H <HEAD> -X<VERB> '<PROTOCOL>://<HOST>:<PORT>/<PATH>?<QUERY_STRING>' -d '<BODY>'

# 例子
curl -H 'content-Type:application/json' --XGET 'http://localhost:9200/_count?pretty'
```

可以按顺序执行每个 sh，细看里面的命令来理解每个指令做的事情，结合文档来看，文档地址: [文档](https://www.elastic.co/guide/en/elasticsearch/reference/current/getting-started.html#getting-started-index-creation)
