# 包含的基本字段
#  - filter 同 bool 下的 filter，filter 语义，匹配的文档才会被选中
#  - boost 给 constant_score 命中的文档赋予分值权重

# 创建文档
curl -X POST "localhost:9200/constant_score/_doc?pretty" -H "Content-Type: application/json" -d'
{
  "user": {
    "id": "kimchy 1"
  },
  "age": 15,
  "tags": "production"
}
'
curl -X POST "localhost:9200/constant_score/_doc?pretty" -H 'Content-Type: application/json' -d'
{
  "user": {
    "id": "kimchy 3"
  },
  "age": 21,
  "tags": "env1"
}
'

# 查询
# 可以看到匹配到的文档，_score 都是 1.2
curl -X POST "localhost:9200/constant_score/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "constant_score": {
      "filter": {
        "term": {"user.id": "kimchy"}
      },
      "boost": 1.2
    }
  }
}
'

# 尝试多条查询
# 可以看到同时匹配了两条的 score 是 3.2，只匹配到 user.id 一条的 score 是 1.2
curl -X POST "localhost:9200/constant_score/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool": {
      "should": [
        { "constant_score": {
            "filter": {
              "term": { "user.id": "kimchy" }
            },
            "boost": 1.2
          }
        },
        { "constant_score": {
            "filter": {
              "term": { "tags": "env1" }
            },
            "boost": 2
          }
        }
      ]
    }
  }
}
'
