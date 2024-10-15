# field_value_factor 函数
# 直接使用文档字段进行算分
# 包含几个分量
#   - field 要计算的字段
#   - factor 字段值乘上的乘数
#   - modifier 分量计算的函数
#     - log 以 10 为底取对数
#     - log1p 以 10 为底取对数，但是分值会先加 1，避免返回负数分值报错
#     - log2p 以 10 为底取对数，但是分值会先加 2
#     - ln 以 2 为底取自然对数
#     - ln1p 同 log1p
#     - ln2p 同 log2p
#     - square 平方
#     - sqrt 开方
#     - reciprocal 取倒数
#   - missing 如果要计算的字段不存在，计算分值取的默认值
# 公式为 modifier(factor * doc[<field>].value)

# 创建文档
curl -X POST "localhost:9200/function_score_field_value_factor/_doc?pretty" -H "Content-Type: application/json" -d'
{
  "user": {
    "id": "kimchy 1"
  },
  "age": 15,
  "tags": "production"
}
'

# 尝试对 age 进行一个 sqrt（开方）
# 可以看到分值是 sqrt(1.2 * doc["age"].value) = 4.242641
curl -X GET "localhost:9200/function_score_field_value_factor/_search?pretty" -H "Content-Type: application/json" -d'
{
  "query": {
    "function_score": {
      "field_value_factor": {
        "field": "age",
        "factor": 1.2,
        "modifier": "sqrt",
        "missing": 1
      },
      "boost_mode": "replace"
    }
  }
}
'

# missing 字段
# 这里可以看到变成了 sqrt(1.2 * 1) = 1.0954452
curl -X GET "localhost:9200/function_score_field_value_factor/_search?pretty" -H "Content-Type: application/json" -d'
{
  "query": {
    "function_score": {
      "field_value_factor": {
        "field": "age",
        "factor": 1.2,
        "modifier": "sqrt",
        "missing": 1
      },
      "boost_mode": "replace"
    }
  }
}
'
