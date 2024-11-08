# multi_match 对多个字段同时应用 match 规则
# 这个匹配的核心是使用 type 指定匹配的规则：
#    - best_fields 对多个字段应用同一个规则，然后将分值最高的作为匹配的最终分值，类似 dis_max，支持 match 支持的可选项
#    - most_fields 多个字段中任意一个 match 到 query 即匹配成功，将所有匹配到的规则的得分加起来作为最终得分，类似于 bool 的 should 里对每个字段定义 match，支持 match 支持的可选项
#    - phrase 和 phrase_prefix 对多个字段应用 phrase 规则，选取最高的那个，类似于 dis_max 下嵌套多个 match_phrase_prefix 或者 match_phrase，支持 match 和 phrase、phrase_prefix 的可选项
#    - cross_fields 尽量交叉匹配，将 query 的词尽量分散到不同字段上，越分散得分越高，取最高分作为文档的匹配得分
#    - bool_prefix 对所有字段应用 match_bool_prefix 规则，类似于 most_fields，得分为总和
# index.query.default_field 如果没有指定 fields，默认使用这个设置里的字段进行查询

# 添加文档
curl -X POST "localhost:9200/multi_match/_doc?pretty" -H "Content-Type: application/json" -d'
{
  "user": {
    "id": "kimchy 1"
  },
  "text2": "my",
  "text": "my favorite fruit is apple"
}
'
curl -X POST "localhost:9200/multi_match/_doc?pretty" -H "Content-Type: application/json" -d'
{
  "user": {
    "id": "kimchy 3"
  },
  "text": "my favorite fruit is appl"
}
'
curl -X POST "localhost:9200/multi_match/_doc?pretty" -H "Content-Type: application/json" -d'
{
  "user": {
    "id": "kimchy 2"
  },
  "text": "your favorite fruit is peach"
}
'

# 基本查询
# 支持通配符匹配
curl -X GET "localhost:9200/multi_match/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "multi_match": {
        "query": "apple",
        "fields": ["text", "text2"]
    }
  }
}
'

