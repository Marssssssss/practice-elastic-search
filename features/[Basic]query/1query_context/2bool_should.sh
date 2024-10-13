# bool 下的 should 是 query 上下文
# should 标记的可有可无，只有一个 should 的情况就是必须，否则等同于 or 其他条件

# 添加文档
curl -X POST "localhost:9200/bool_should/_doc?pretty" -H 'Content-Type: application/json' -d'
{
  "name": "snow",
  "tag": "book"
}
'
curl -X POST "localhost:9200/bool_should/_doc?pretty" -H 'Content-Type: application/json' -d'
{
  "name": "snow 1",
  "tag": "book"
}
'
curl -X POST "localhost:9200/bool_should/_doc?pretty" -H 'Content-Type: application/json' -d'
{
  "name": "snow 2",
  "tag": "book2"
}
'

# 首先单个 should 查询，全都没有匹配到
# 如果匹配 snow 就全都匹配到了
curl -X POST "localhost:9200/bool_should/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool" : {
      "should" : {
        "term" : { "name" : "snow3"}
      }
    }
  }
}
'

# 这个时候再试试多个 should 匹配
# 其中 book2 匹配到了，因此对应的文档被提出来
curl -X POST "localhost:9200/bool_should/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool" : {
      "should" : [
        { "term" : { "name" : "aaa"} },
        { "term" : { "tag" : "book2"} }
      ]
    }
  }
}
'

# 同样也是字段越精准得分越高，字段命中数越多得分越高
curl -X POST "localhost:9200/bool_should/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool" : {
      "should" : [
        { "term" : { "name" : "snow"} },
        { "term" : { "tag" : "book"} }
      ]
    }
  }
}
'