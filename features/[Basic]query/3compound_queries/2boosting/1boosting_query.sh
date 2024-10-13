# boosting 的基本结构
#  - positive，积累正分的匹配
#  - negative，积累负分的匹配
#  - negative_boost 负分匹配权重，如果匹配到 negative，则正分最后会乘上这个权重值

# 创建文档
curl -x POST "localhost:9200/boosting_query/_doc?pretty" -H "Content-Type: application/json" -d'
{
  "user": {
    "id": "kimchy 1"
  },
  "age": 15,
  "tags": "production"
}
'
curl -X POST "localhost:9200/boosting_query/_doc?pretty" -H 'Content-Type: application/json' -d'
{
  "user": {
    "id": "kimchy 2"
  },
  "age": 21,
  "tags": "production"
}
'
curl -X POST "localhost:9200/boosting_query/_doc?pretty" -H 'Content-Type: application/json' -d'
{
  "user": {
    "id": "kimchy 3"
  },
  "age": 21,
  "tags": "env1"
}
'
curl -X POST "localhost:9200/boosting_query/_doc?pretty" -H 'Content-Type: application/json' -d'
{
  "user": {
    "id": "kimchy 3"
  },
  "age": 21,
  "tags": "production env1"
}
'

# 基本格式查询
# negative_boost 设置成 1.0 后，匹配到 negative 的 doc 和没匹配到的分值是一样的
curl -X POST "localhost:9200/boosting_query/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "boosting" : {
      "positive" : {
        "term" : { "user.id" : "kimchy" }
      },
      "negative": {
        "term" : { "tags" : "env1" }
      },
      "negative_boost": 1.0
    }
  }
}
'

# 尝试使用更小的 negative_boost
# 可以看到 negative_boost 的影响就是乘上 positive 产生的分值
curl -X POST "localhost:9200/boosting_query/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "boosting" : {
      "positive" : {
        "term" : { "user.id" : "kimchy" }
      },
      "negative": {
        "term" : { "tags" : "env1" }
      },
      "negative_boost": 0.5
    }
  }
}
'
