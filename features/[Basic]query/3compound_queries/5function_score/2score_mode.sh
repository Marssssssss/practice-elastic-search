# score_mode 定义文档匹配多个 function 的情况下，其 weight 怎么计算
# 有五种模式
#   - sum 相加
#   - avg 加权平均
#   - first 第一个匹配的权重
#   - max 最大匹配
#   - min 最小匹配

# 创建文档
curl -X POST "localhost:9200/function_score_score_mode/_doc?pretty" -H "Content-Type: application/json" -d'
{
  "user": {
    "id": "kimchy 1"
  },
  "age": 15,
  "tags": "production"
}
'

# sum 模式，weight 会进行相加
# 所以这里分值为 (2 + 3) * 5 = 25
curl -X GET "localhost:9200/function_score_score_mode/_search?pretty" -H 'Content-Type: application/json' -d'
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
          "filter": { "match": { "tags": "production" } },
          "weight": 3
        }
      ],
      "score_mode": "sum"
    }
  }
}
'

# avg 模式，weight 会进行加权平均
# avg 的规则是每个 function 都按照 score * weight 得到自己的分数，所有分数相加后除以 weight 总和
# 下面的例子里，随机数的 function 权重被拉的很低，多次执行后发现 random 的随机范围很小，可以调整 random function 里 weight 值来提升 random 的随机范围
curl -X GET "localhost:9200/function_score_score_mode/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "function_score": {
      "query": { "match_all": {} },
      "boost": "5",
      "functions": [
        {
          "filter": { "match": { "user.id": "kimchy" } },
          "random_score": {},
          "weight": 2
        },
        {
          "filter": { "match": { "tags": "production" } },
          "weight": 30
        },
        {
          "filter": { "match": { "age": 15 } },
          "weight": 30
        }
      ],
      "score_mode": "avg"
    }
  }
}
'

# first 模式，第一个匹配到 weight 作为最终的评分
# 下面的 case 可以看到第二个 function 最先匹配到，所以分数为 30 * 5 = 150
curl -X POST "localhost:9200/function_score_score_mode/_doc?pretty" -H "Content-Type: application/json" -d'
{
  "user": {
    "id": "who 1"
  },
  "age": 15,
  "tags": "production"
}
'
curl -X GET "localhost:9200/function_score_score_mode/_search?pretty" -H 'Content-Type: application/json' -d'
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
          "filter": { "match": { "tags": "production" } },
          "weight": 30
        },
        {
          "filter": { "match": { "age": 15 } },
          "weight": 40
        }
      ],
      "score_mode": "first"
    }
  }
}
'

# max 模式，所有 function 里面最高的评分作为最终评分
curl -X GET "localhost:9200/function_score_score_mode/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "function_score": {
      "query": { "match_all": {} },
      "boost": "5",
      "functions": [
        {
          "filter": { "match": { "user.id": "kimchy" } },
          "weight": 40
        },
        {
          "filter": { "match": { "tags": "production" } },
          "weight": 30
        },
        {
          "filter": { "match": { "age": 15 } },
          "weight": 20
        }
      ],
      "score_mode": "max"
    }
  }
}
'

# min 模式，和 max 相反，评分最低的作为最终评分
curl -X GET "localhost:9200/function_score_score_mode/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "function_score": {
      "query": { "match_all": {} },
      "boost": "5",
      "functions": [
        {
          "filter": { "match": { "user.id": "kimchy" } },
          "weight": 20
        },
        {
          "filter": { "match": { "tags": "production" } },
          "weight": 30
        },
        {
          "filter": { "match": { "age": 15 } },
          "weight": 50
        }
      ],
      "score_mode": "min"
    }
  }
}
'
