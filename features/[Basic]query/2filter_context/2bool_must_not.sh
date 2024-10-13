# must_not 是一个 filter 上下文语义的查询操作
# filter 不会计分且能缓存，性能上相比 query 上下文语义据说拥有更好的性能

# 添加文档
curl -X POST "localhost:9200/bool_must_not/_doc?pretty" -H 'Content-Type: application/json' -d'
{
  "name": "snow 1",
  "tag": "book"
}
'
curl -X POST "localhost:9200/bool_must_not/_doc?pretty" -H 'Content-Type: application/json' -d'
{
  "name": "snow",
  "tag": "book"
}
'

# 进行 must_not 查询
# 单个 must_not 查询没有返回内容
curl -X POST "localhost:9200/bool_must_not/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool" : {
      "must_not": {
        "term" : { "name" : "snow" }
      }
    }
  }
}
'

# 复合查询，这个时候能找到文档了
# 其中能搜索出两个包含 snow 的文档，但是其中一个 snow 1 因为指定 must_not 1 被剔除了，最终只返回一个文档
curl -X POST "localhost:9200/bool_must_not/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool" : {
      "must": {
        "term": {"name": "snow"}
      },
      "must_not": {
        "term" : { "name" : "1" }
      }
    }
  }
}
'