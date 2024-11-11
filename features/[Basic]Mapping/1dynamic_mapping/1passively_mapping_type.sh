# 不主动指定字段类型的情况下，第一次添加的值将决定字段的类型
#  - 例如添加一个字段 age，值是 1，这个时候查看 mapping 会发现是 long
#  - 如果是添加一个字段 age，值为 1.0，这个时候查看 mapping 类型是 float

# 创建索引，查看 mapping，此时类型为空
curl -H 'content-Type:application/json' -XPUT 'http://127.0.0.1:9200/dynamic_mapping_passively_mapping_type'
curl -X GET "localhost:9200/dynamic_mapping_passively_mapping_type/_mapping?pretty"

# 创建文档，此时 age 类型为 float
curl -X POST "localhost:9200/dynamic_mapping_passively_mapping_type/_doc?pretty" -H "Content-Type: application/json" -d'
{ "age": 15.0 }
'
curl -X GET "localhost:9200/dynamic_mapping_passively_mapping_type/_mapping?pretty"

# 重新创建索引
curl -X DELETE "localhost:9200/dynamic_mapping_passively_mapping_type?pretty"
curl -H 'content-Type:application/json' -XPUT 'http://127.0.0.1:9200/dynamic_mapping_passively_mapping_type'
curl -X GET "localhost:9200/dynamic_mapping_passively_mapping_type/_mapping?pretty"

# 创建文档，此时 age 类型为 long
curl -X POST "localhost:9200/dynamic_mapping_passively_mapping_type/_doc?pretty" -H "Content-Type: application/json" -d'
{ "age": 15 }
'
curl -X GET "localhost:9200/dynamic_mapping_passively_mapping_type/_mapping?pretty"


# 类型会影响一些计算的东西
#   - 比如 decay_function 里，如果是 long 类型，则计算前会先对字段值取整
#   - 尽管类型是 long，文档赋值的时候字段仍然可以赋值成小数，但是处理时可能会按照 long 处理
# 比如下面这个查询，文档分值结果
#   - age = 14.5 时分值为 1.0，此时等于 14 的分值
#   - age = 145 时分值为 0.33
curl -X DELETE "localhost:9200/dynamic_mapping_passively_mapping_type?pretty"
curl -H 'content-Type:application/json' -XPUT 'http://127.0.0.1:9200/dynamic_mapping_passively_mapping_type'
curl -X GET "localhost:9200/dynamic_mapping_passively_mapping_type/_mapping?pretty"
curl -X POST "localhost:9200/dynamic_mapping_passively_mapping_type/_bulk?pretty" -H "Content-Type: application/json" -d'
{ "index" : { "_index" : "dynamic_mapping_passively_mapping_type" } }
{ "age": 15 }
{ "index" : { "_index" : "dynamic_mapping_passively_mapping_type" } }
{ "age": 14.5 }
'
curl -X GET "localhost:9200/dynamic_mapping_passively_mapping_type/_mapping?pretty"
curl -X GET "localhost:9200/dynamic_mapping_passively_mapping_type/_search?pretty" -H "Content-Type: application/json" -d'
{
  "query": {
    "function_score": {
      "linear": {
        "age": {
          "origin": "14",
          "scale": 1,
          "offset": "0",
          "decay": 0.33
        }
      },
      "boost_mode": "replace"
    }
  }
}
'
# 但是下面这个查询，文档分值结果
#   - age = 14.5 时分值为 0.665，是衰减的正确值
#   - age = 145 时分值为 0.33
# 很明显同样的 age 值在类型不一样的时候，这个查询的结果也不一样
curl -X DELETE "localhost:9200/dynamic_mapping_passively_mapping_type?pretty"
curl -H 'content-Type:application/json' -XPUT 'http://127.0.0.1:9200/dynamic_mapping_passively_mapping_type'
curl -X GET "localhost:9200/dynamic_mapping_passively_mapping_type/_mapping?pretty"
curl -X POST "localhost:9200/dynamic_mapping_passively_mapping_type/_bulk?pretty" -H "Content-Type: application/json" -d'
{ "index" : { "_index" : "dynamic_mapping_passively_mapping_type" } }
{ "age": 15.0 }
{ "index" : { "_index" : "dynamic_mapping_passively_mapping_type" } }
{ "age": 14.5 }
'
curl -X GET "localhost:9200/dynamic_mapping_passively_mapping_type/_mapping?pretty"
curl -X GET "localhost:9200/dynamic_mapping_passively_mapping_type/_search?pretty" -H "Content-Type: application/json" -d'
{
  "query": {
    "function_score": {
      "linear": {
        "age": {
          "origin": "14",
          "scale": 1,
          "offset": "0",
          "decay": 0.33
        }
      },
      "boost_mode": "replace"
    }
  }
}
'