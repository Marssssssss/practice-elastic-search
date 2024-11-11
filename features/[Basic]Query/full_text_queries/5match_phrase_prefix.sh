# match_phrase_prefix，匹配 "term term ... term prefix" 形式的短语
# 有点像 match_bool_prefix 和 match_phrase 的结合
# 参数：
#   - slop，同 match_phrase
#   - analyzer，同 match_bool_prefix，指定分词规则
#   - max_expansions，前缀词允许最多匹配的数量，假如文档里有超过这个数量的符合前缀的词，后面的词将被视作不匹配
#   - zero_terms_query，分词为空结果时的返回策略，同 match_bool_prefix

# 创建文档
curl -X POST "localhost:9200/match_phrase_prefix/_doc?pretty" -H "Content-Type: application/json" -d'
{
  "user": {
    "id": "kimchy 1"
  },
  "text": "my favorite fruit is apple"
}
'
curl -X POST "localhost:9200/match_phrase_prefix/_doc?pretty" -H "Content-Type: application/json" -d'
{
  "user": {
    "id": "kimchy 3"
  },
  "text": "my favorite fruit is appl"
}
'
curl -X POST "localhost:9200/match_phrase_prefix/_doc?pretty" -H "Content-Type: application/json" -d'
{
  "user": {
    "id": "kimchy 2"
  },
  "text": "your favorite fruit is peach"
}
'

# 基本查询
curl -X GET "localhost:9200/match_phrase_prefix/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match_phrase_prefix": {
      "text": {
        "query": "fruit is a"
      }
    }
  }
}
'

# 和 match_phrase 一样，可以使用 slop，限制允许多少次移动凑成连续短语串来匹配
curl -X GET "localhost:9200/match_phrase_prefix/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match_phrase_prefix": {
      "text": {
        "query": "my is a",
        "slop": 2
      }
    }
  }
}
'
