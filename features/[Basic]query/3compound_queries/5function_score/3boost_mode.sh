# boost_mode 定义了原文档的分数（query 的时候赋予的）和 function 分数的组合模式
# 有几种模式：
#  - multiply 相乘
#  - replace 直接使用 function 分数，覆盖原来的分数
#  - sum 相加
#  - avg 取平均
#  - max 取最大值
#  - min 取最小值
# 文档最终分值公式 boost_mode(score_mode(function1, function2...), boost * doc_score)
#   - 其中 boost * doc_score 被称作 query_score

# 创建文档
curl -X POST "localhost:9200/function_score_boost_mode/_doc?pretty" -H "Content-Type: application/json" -d'
{
  "user": {
    "id": "kimchy 1"
  },
  "age": 15,
  "tags": "production"
}
'

# 进行查询获取原本的评分，结果为 0.2876821
curl -X GET "localhost:9200/function_score_boost_mode/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "function_score": {
      "query": {
        "match": { "user.id": "kimchy" }
      },
      "functions": [
        {
          "filter": { "match": { "user.id": "kimchy" } },
          "weight": 1
        }
      ],
      "score_mode": "sum"
    }
  }
}
'

# 设置 boost，可以看到源文档的分数乘上了 boost
curl -X GET "localhost:9200/function_score_boost_mode/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "function_score": {
      "query": {
        "match": { "user.id": "kimchy" }
      },
      "boost": 2,
      "functions": [
        {
          "filter": { "match": { "user.id": "kimchy" } },
          "weight": 1
        }
      ],
      "score_mode": "sum"
    }
  }
}
'

# multiply 模式，也是默认的 weight 和 score 模式
# 下面的结果为 (0.2876821 * 2) * (2 + 3) = 1.1507283
curl -X GET "localhost:9200/function_score_boost_mode/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "function_score": {
      "query": {
        "match": { "user.id": "kimchy" }
      },
      "boost": 2,
      "functions": [
        {
          "filter": { "match": { "user.id": "kimchy" } },
          "weight": 2
        },
        {
          "filter": { "match": { "age": 15 } },
          "weight": 3
        }
      ],
      "score_mode": "sum",
      "boost_mode": "multiply"
    }
  }
}
'

# replace 模式，function 的分值直接替代 query_score
# 下面的结果为 2 + 3 = 5
curl -X GET "localhost:9200/function_score_boost_mode/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "function_score": {
      "query": {
        "match": { "user.id": "kimchy" }
      },
      "boost": 2,
      "functions": [
        {
          "filter": { "match": { "user.id": "kimchy" } },
          "weight": 2
        },
        {
          "filter": { "match": { "age": 15 } },
          "weight": 3
        }
      ],
      "score_mode": "sum",
      "boost_mode": "replace"
    }
  }
}
'

# sum 模式，query_score 和 score_mode 直接相加
# 下面的结果为 (0.2876821 * 2) + (2 + 3) = 5.575364
curl -X GET "localhost:9200/function_score_boost_mode/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "function_score": {
      "query": {
        "match": { "user.id": "kimchy" }
      },
      "boost": 2,
      "functions": [
        {
          "filter": { "match": { "user.id": "kimchy" } },
          "weight": 2
        },
        {
          "filter": { "match": { "age": 15 } },
          "weight": 3
        }
      ],
      "score_mode": "sum",
      "boost_mode": "sum"
    }
  }
}
'

# sum 模式，query_score 和 score_mode 取平均
# 下面的结果为 ((0.2876821 * 2) + (2 + 3)) / 2 = 2.787682
curl -X GET "localhost:9200/function_score_boost_mode/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "function_score": {
      "query": {
        "match": { "user.id": "kimchy" }
      },
      "boost": 2,
      "functions": [
        {
          "filter": { "match": { "user.id": "kimchy" } },
          "weight": 2
        },
        {
          "filter": { "match": { "age": 15 } },
          "weight": 3
        }
      ],
      "score_mode": "sum",
      "boost_mode": "avg"
    }
  }
}
'

# max 模式，query_score 和 score_mode 取最大值
# 下面的结果为 max((0.2876821 * 2), (2 + 3)) = 5
curl -X GET "localhost:9200/function_score_boost_mode/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "function_score": {
      "query": {
        "match": { "user.id": "kimchy" }
      },
      "boost": 2,
      "functions": [
        {
          "filter": { "match": { "user.id": "kimchy" } },
          "weight": 2
        },
        {
          "filter": { "match": { "age": 15 } },
          "weight": 3
        }
      ],
      "score_mode": "sum",
      "boost_mode": "max"
    }
  }
}
'

# min 模式，query_score 和 score_mode 取最小值
# 下面的结果为 min((0.2876821 * 2), (2 + 3)) = 0.5753642
curl -X GET "localhost:9200/function_score_boost_mode/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "function_score": {
      "query": {
        "match": { "user.id": "kimchy" }
      },
      "boost": 2,
      "functions": [
        {
          "filter": { "match": { "user.id": "kimchy" } },
          "weight": 2
        },
        {
          "filter": { "match": { "age": 15 } },
          "weight": 3
        }
      ],
      "score_mode": "sum",
      "boost_mode": "min"
    }
  }
}
'