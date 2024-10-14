# function_score 支持自定义文档的评分规则，其逻辑如下
#  1.先通过 query 筛选出候选文档，每一个 function 都会对候选文档使用指定的函数进行评分计算
#  2.同一个文档被多个 function 命中时，可以指定评分叠加的规则
# 基础结构
#  - query 基本筛选规则，筛选出最初的一组文档
#  - boost 文档评分乘数，默认是 1.0
#  - functions 对候选文档依次执行的 function，首先匹配 filter，匹配成功后才会执行评分计算，默认情况下多个匹配之间的 weight 会相乘
#     - 只有单个 function 的时候直接写在 function_score 块下，如果有多个才需要写 functions
#     - weight 字段只能用在 functions 下

# 创建文档
curl -X POST "localhost:9200/function_score/_doc?pretty" -H "Content-Type: application/json" -d'
{
  "user": {
    "id": "kimchy 1"
  },
  "age": 15,
  "tags": "production"
}
'
curl -X POST "localhost:9200/function_score/_doc?pretty" -H 'Content-Type: application/json' -d'
{
  "user": {
    "id": "kimchy 2"
  },
  "age": 21,
  "tags": "env"
}
'
curl -X POST "localhost:9200/function_score/_doc?pretty" -H 'Content-Type: application/json' -d'
{
  "user": {
    "id": "who 2"
  },
  "age": 21,
  "tags": "env"
}
'

# 进行查询
# 对于上面的第二个文档，两个 function 都能匹配到，所以最后的的得分是 2(weight) * 3(weight) * 5(boost) = 30
# 同理对于其他两个都是只匹配到一个条件的，分值为 2 * 5 = 10 或者 3 * 5 = 15
curl -X GET "localhost:9200/function_score/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "function_score": {
      "query": { "match_all": {} },
      "boost": "5",
      "functions": [
        {
          "filter": { "match": { "user.id": "kimchy" } },
          "weight": 2
        },
        {
          "filter": { "match": { "tags": "env" } },
          "weight": 3
        }
      ]
    }
  }
}
'

# 控制 query 的匹配
# 这里用了个 bool 的 must_not 剔除了 age 为 15 的文档
curl -X GET "localhost:9200/function_score/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "function_score": {
      "query": {
        "bool": {
          "must_not": {
            "term": {"age" : 15}
          }
        }
      },
      "boost": "5",
      "functions": [
        {
          "filter": { "match": { "user.id": "kimchy" } },
          "weight": 2
        },
        {
          "filter": { "match": { "tags": "env" } },
          "weight": 3
        }
      ]
    }
  }
}
'
