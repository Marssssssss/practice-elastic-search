# random_score 函数
# 根据 seed 和 field 生成指定随机数
#  - seed，不指定情况下每次执行结果都不一样
#  - field，推荐使用每个文档唯一的字段，可以用文档中的字段，也可以用 _seq_no、_id 这种字段

# 只指定 seed 不指定 field 的情况不推荐，会消耗很多内存
#  - 原因是默认会加载 _id 的元数据，这个元数据很占内存
# 只指定 field 的情况下，每次生成随机数都不一样
# 两个都不指定的情况下，默认使用 Lucene doc 的 ids 来作为随机数源，每次生成的都不一样
# 如果需要每次都生成一样的随机数，指定 seed 和 field 就行

# 构造文档
curl -X POST "localhost:9200/function_score_random_score/_doc?pretty" -H "Content-Type: application/json" -d'
{
  "user": {
    "id": "kimchy 1"
  },
  "age": 15,
  "tags": "production"
}
'

# 默认情况下查询
# 每次生成的数都不一样，生成 [0, 1) 范围的数
curl -X GET "localhost:9200/function_score_random_score/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "function_score": {
      "query": { "match_all": {} },
      "random_score": {}
    }
  }
}
'

# 默认情况下查询，指定 weight
# 生成的数会乘上 weight
curl -X GET "localhost:9200/function_score_random_score/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "function_score": {
      "query": { "match_all": {} },
      "functions": [
        {
          "random_score": {},
          "weight": 10
        }
      ]
    }
  }
}
'

# 指定 seed 和 field，多次生成相同的数
curl -X GET "localhost:9200/function_score_random_score/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "function_score": {
      "query": { "match_all": {} },
      "random_score": {
        "seed": 10,
        "field": "age"
      }
    }
  }
}
'
