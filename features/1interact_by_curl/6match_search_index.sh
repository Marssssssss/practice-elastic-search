# GET books/_search
# match 查询指定的文档，可以匹配字段
# 比如下面搜索 name 包含 brave 的文档，会搜到一个文档，如果有多个的话可能命中多个文档
# 这个查询只支持单个字段查询，多字段查询还有很多其他姿势，可以参照文档 =。=
curl -X GET "localhost:9200/books/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match": {
      "name": "brave"
    }
  }
}
'
