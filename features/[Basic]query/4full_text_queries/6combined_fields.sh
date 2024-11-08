# combined_fields 可以同时对多个字段进行匹配，取 or 逻辑
# 支持的参数：
#   - auto_generate_synonyms_phrase_query，TODO 待研究
#   - operator，与和或两种，默认为 or，这个是对分词的逻辑规则，不是对字段的
#      - or，匹配的 text 里面有一个分词匹配到就行
#      - and，所有分词都要匹配到
#   - minimum_should_match，至少要匹配到多少个词才能匹配文档，同 operator（针对分词，不针对字段）
#   - zero_terms_query，没有分词的情况下的默认策略，同 match，默认为 none

# 和 multi_match 的对比
#   - multi_match 的每个字段可以使用不同的 analyzer
#   - combined_fields 所有字段必须使用相同的搜索 analyzer

# 创建文档
curl -X POST "localhost:9200/combined_fields/_doc?pretty" -H "Content-Type: application/json" -d'
{
  "user": {
    "id": "kimchy 1"
  },
  "text2": "my",
  "text": "my favorite fruit is apple"
}
'
curl -X POST "localhost:9200/combined_fields/_doc?pretty" -H "Content-Type: application/json" -d'
{
  "user": {
    "id": "kimchy 3"
  },
  "text": "my favorite fruit is appl"
}
'
curl -X POST "localhost:9200/combined_fields/_doc?pretty" -H "Content-Type: application/json" -d'
{
  "user": {
    "id": "kimchy 2"
  },
  "text": "your favorite fruit is peach"
}
'

# 基本查询
# 字段支持通配符匹配
curl -X GET "localhost:9200/combined_fields/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "combined_fields": {
        "query": "apple",
        "fields": ["text", "text2"]
    }
  }
}
'

# operator 选项
# 使用 and 查询，发现仍然能匹配到（基本查询默认是 or），说明不是对字段的 and
# 使用 and 查询 your apple，此时都匹配不到了
curl -X GET "localhost:9200/combined_fields/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "combined_fields": {
        "query": "apple",
        "fields": ["text", "text2"],
        "operator": "and"
    }
  }
}
'
curl -X GET "localhost:9200/combined_fields/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "combined_fields": {
        "query": "your apple",
        "fields": ["text", "text2"],
        "operator": "and"
    }
  }
}
'

# minimum_should_match 选项
# 设置 2 匹配 my apple，能匹配到
# 设置 3 匹配 my apple peach，匹配不到
curl -X GET "localhost:9200/combined_fields/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "combined_fields": {
        "query": "my apple",
        "fields": ["text", "text2"],
        "minimum_should_match": 2
    }
  }
}
'
curl -X GET "localhost:9200/combined_fields/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "combined_fields": {
        "query": "my apple peach",
        "fields": ["text", "text2"],
        "minimum_should_match": 3
    }
  }
}
'
