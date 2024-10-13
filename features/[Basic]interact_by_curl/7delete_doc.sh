# 根据索引删除文档
# 比如下面删除 id 为 oOppfJIBsXvE0L67SqYR 的文档，id 对应的是文档里面的 _id 字段值
curl -X DELETE "localhost:9200/books/_doc/oOppfJIBsXvE0L67SqYR?pretty" -H 'Content-Type: application/json'
