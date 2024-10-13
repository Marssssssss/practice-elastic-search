# bool 下的 must 就是 query 上下文
# must 标记的字段必须出现在文档中，并且会贡献评分，等同于 and 其他条件

# 添加文档
curl -X POST "localhost:9200/bool_must/_doc?pretty" -H 'Content-Type: application/json' -d'
{
  "name": "snow",
  "tag": "book"
}
'
curl -X POST "localhost:9200/bool_must/_doc?pretty" -H 'Content-Type: application/json' -d'
{
  "name": "snow 1",
  "tag": "book"
}
'
curl -X POST "localhost:9200/bool_must/_doc?pretty" -H 'Content-Type: application/json' -d'
{
  "name": "snow 2",
  "tag": "book2"
}
'

# 查询文档
# term 或者 match 内只支持一个字段的匹配
# 在上面的 case 下会命中两个文档
curl -X POST "localhost:9200/bool_must/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool" : {
      "must" : {
        "term" : { "name" : "snow"}
      }
    }
  }
}
'

# 几个点
# 1.term 虽然两个文档都查询到了，命中最准确的 score 更高（name 就是 snow 的那个文档）
# 2.must 字段匹配必须包含的字段，比如下面的 case 就匹配不到任何一个文档
curl -X POST "localhost:9200/bool_must/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool" : {
      "must" : {
        "term" : { "tag" : "snow"}
      }
    }
  }
}
'

# 可以多个 must 组合成 and 查询
# 这个时候就只命中一个文档了
curl -X POST "localhost:9200/bool_must/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool" : {
      "must" : [
        { "term" : { "name" : "snow"} },
        { "term" : { "tag" : "book2" } }
      ]
    }
  }
}
'
