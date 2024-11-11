# match_bool_prefix 很好理解，就是将 term + term + ... + term + prefix 的 bool 查询糅合到一个字符串里的查询
# 支持 analyzer 进行分词
# 支持 minimum_should_match 和 operator 两个参数，作用和 match 里的一样

# 工作原理上
#   1.先对字符串进行分词
#   2.分好的词按顺序先构造 term 查询，最后一个词构造 perfix 查询，最后将所有查询包到 bool 里面

# TODO 支持 fuzziness、prefix_length、max_expansions、fuzzy_transpositions 和 fuzzy_rewrite 参数，待研究

# 创建文档
curl -X POST "localhost:9200/match_bool_prefix/_doc?pretty" -H "Content-Type: application/json" -d'
{
  "user": {
    "id": "kimchy 1"
  },
  "text": "my favorite fruit is apple"
}
'
curl -X POST "localhost:9200/match_bool_prefix/_doc?pretty" -H "Content-Type: application/json" -d'
{
  "user": {
    "id": "kimchy 3"
  },
  "text": "my favorite fruit is appl"
}
'
curl -X POST "localhost:9200/match_bool_prefix/_doc?pretty" -H "Content-Type: application/json" -d'
{
  "user": {
    "id": "kimchy 2"
  },
  "text": "your favorite fruit is peach"
}
'

# 基本查询，所有文档都能匹配到
curl -X GET "localhost:9200/match_bool_prefix/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match_bool_prefix": {
      "text": {
        "query": "my fruit ap"
      }
    }
  }
}
'

# 最后一个 term 为前缀查询
# 先查询 pt，无前缀匹配
# 然后查询 pe，匹配到一个文档
curl -X GET "localhost:9200/match_bool_prefix/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match_bool_prefix": {
      "text": {
        "query": "pt"
      }
    }
  }
}
'
curl -X GET "localhost:9200/match_bool_prefix/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match_bool_prefix": {
      "text": {
        "query": "pe"
      }
    }
  }
}
'

# 指定分词匹配逻辑
# 先匹配 your 或者 app 前缀，匹配到所有文档，默认为 or
# 指定最小匹配数为 2，匹配不到文档
# 再匹配 your 且 app 前缀，匹配不到文档
curl -X GET "localhost:9200/match_bool_prefix/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match_bool_prefix": {
      "text": {
        "query": "your app"
      }
    }
  }
}
'
curl -X GET "localhost:9200/match_bool_prefix/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match_bool_prefix": {
      "text": {
        "query": "your app",
        "minimum_should_match": 2
      }
    }
  }
}
'
curl -X GET "localhost:9200/match_bool_prefix/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match_bool_prefix": {
      "text": {
        "query": "your app",
        "operator": "and"
      }
    }
  }
}
'
# 上面查询等价于
#{
#  "query": {
#    "bool": {
#      "must": [
#        { "term": { "text": "your" }},
#        { "prefix": { "text": "app" }}
#      ]
#    }
#  }
#}