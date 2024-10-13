# filter 是一个 filter 上下文语义的查询操作
# filter 不会计分且能缓存，性能上相比 query 上下文语义据说拥有更好的性能

# 添加文档
curl -X POST "localhost:9200/bool_filter/_doc?pretty" -H 'Content-Type: application/json' -d'
{
  "name": "snow 1",
  "tag": "book"
}
'
curl -X POST "localhost:9200/bool_filter/_doc?pretty" -H 'Content-Type: application/json' -d'
{
  "name": "snow",
  "tag": "book"
}
'

# 进行 filter 查询
# 查询出来的结果没有什么顺序（可能是按照加入的顺序，或者算法数据结构处理后的顺序），分值都一律是 0
curl -X POST "localhost:9200/bool_filter/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool" : {
      "filter": {
        "term" : { "name" : "snow" }
      }
    }
  }
}
'

