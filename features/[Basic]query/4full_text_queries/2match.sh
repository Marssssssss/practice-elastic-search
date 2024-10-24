# match 匹配文本，数字，日期或者布尔值
# match 指定的文本在匹配前会先进行分析

# match 的工作原理其实类似于 boolean 查询，它将文本进行分词，然后对所有词构造一个 boolean 查询
# 参数：
#    - query 具体要查询的内容，可以是文本、数字、布尔值或者日期
#    - analyzer 用来在搜索前对 query 内容进行分词的分析器，默认情况下使用的是 index-time analyzer，如果没有匹配到分词器，就会使用索引的默认分词器
#    - auto_generate_synonyms_phrase_query TODO 待研究
#    - boost 指定匹配的相关分，影响文档最终的得分
#    - fuzziness 用于模糊匹配，指定最大允许的编辑距离
#    - max_expansions TODO 待研究
#    - prefix_length 模糊匹配语义下，前缀不变的最小数量
#    - fuzzy_transpositions 支持字符换位模糊匹配（比如 ab 和 ba）
#    - fuzzy_rewrite TODO 待研究
#    - lenient 忽略匹配类型和字段类型不匹配的错误，默认为 false
#    - operator 匹配的逻辑规则
#        - or 或规则，默认
#        - and 与规则
#    - minimum_should_match 最小应该匹配的分词数量
#    - zero_terms_query 如果分词器剔除了所有的词，应该怎么返回文档
#        - none 没有文档返回，默认
#        - all 返回所有文档

# 创建 docs
curl -X POST "localhost:9200/full_text_queries_match/_doc?pretty" -H "Content-Type: application/json" -d'
{
  "user": {
    "id": "kimchy 1"
  },
  "text": "my favorite fruit is apple"
}
'
curl -X POST "localhost:9200/full_text_queries_match/_doc?pretty" -H "Content-Type: application/json" -d'
{
  "user": {
    "id": "kimchy 3"
  },
  "text": "my favorite fruit is appl"
}
'
curl -X POST "localhost:9200/full_text_queries_match/_doc?pretty" -H "Content-Type: application/json" -d'
{
  "user": {
    "id": "kimchy 2"
  },
  "text": "your favorite fruit is peach"
}
'

# 基本查询 case
curl -X GET "localhost:9200/full_text_queries_match/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match": {
      "text": {
        "query": "my fruit apple"
      }
    }
  }
}
'

# 指定相关分 boost
# 最终分值 = 原分值 * boost
curl -X GET "localhost:9200/full_text_queries_match/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match": {
      "text": {
        "query": "my fruit apple",
        "boost": 1.2
      }
    }
  }
}
'

# 模糊匹配
# 先匹配 attle，没有匹配到
# 指定 fuzziness 为 2，可以匹配到
# 指定 fuzziness 为 1 就匹配不到了，因为 attle 相对 apple 有两个字母的修改
curl -X GET "localhost:9200/full_text_queries_match/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match": {
      "text": {
        "query": "attle"
      }
    }
  }
}
'
curl -X GET "localhost:9200/full_text_queries_match/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match": {
      "text": {
        "query": "attle",
        "fuzziness": 2
      }
    }
  }
}
'
curl -X GET "localhost:9200/full_text_queries_match/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match": {
      "text": {
        "query": "attle",
        "fuzziness": 1
      }
    }
  }
}
'

# 逻辑匹配
# 首先默认 or，下面的查询匹配到所有文档
# 随后设置 and，只有一个文档匹配到
curl -X GET "localhost:9200/full_text_queries_match/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match": {
      "text": {
        "query": "my fruit apple"
      }
    }
  }
}
'
curl -X GET "localhost:9200/full_text_queries_match/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match": {
      "text": {
        "query": "my fruit apple",
        "operator": "and"
      }
    }
  }
}
'

# 要求最小分词数量匹配
# 设置 minimum_should_match 为 1，都能匹配到
# 设置 minimum_should_match 为 3，只有一个文档匹配到
curl -X GET "localhost:9200/full_text_queries_match/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match": {
      "text": {
        "query": "my fruit apple",
        "minimum_should_match": 1
      }
    }
  }
}
'
curl -X GET "localhost:9200/full_text_queries_match/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match": {
      "text": {
        "query": "my fruit apple",
        "minimum_should_match": 3
      }
    }
  }
}
'

# 分词器剔除所有词后匹配策略，这里使用 stop 和数字来模拟无分词的情况
# 默认为 none，啥也匹配不到
# 设置为 all，返回所有文档
curl -X GET "localhost:9200/full_text_queries_match/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match": {
      "text": {
        "query": "2",
        "analyzer": "stop"
      }
    }
  }
}
'
curl -X GET "localhost:9200/full_text_queries_match/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match": {
      "text": {
        "query": "2",
        "analyzer": "stop",
        "zero_terms_query": "all"
      }
    }
  }
}
'
