# intervals 主要匹配文本的片段

# intervals 规则
#   - match，定义一系列 term，只要按照给定的 term 顺序能匹配到就算命中
#      - 例如 "a b c"，句子中包含 a、b 和 c 就能命中，a、b 和 c 之间可以间隔多个字符，间隔的字符数称为 gap，可以自定义最大 gap 数
#   - prefix，匹配定义前缀的 term
#      - 默认最多匹配 128 个 term，超过 128 会报错，可以用 index 的 index_prefix 字段修改限制
#   - wildcard，通配符匹配
#      - 同样默认 128 个 term，超过报错，文档没有指出修改限制的方法
#      - * 匹配 0 个或者多个字符，? 匹配一个字符
#   - fuzzy，模糊匹配，根据距离算法匹配和提供词相近的词
#   - all_of，上面几个单查询的联合规则，包含的所有规则都必须匹配到文档才能命中
#   - any_of，上面几个单查询的联合规则，包含的规则有一个匹配到即可

# TODO 研究下 128 个 term 限制是什么意思，每个文档最多 128 种 term 还是整个 index 最多只能匹配到 128 个 term

# 创建文档
curl -X POST "localhost:9200/intervals_queries/_doc?pretty" -H "Content-Type: application/json" -d'
{
  "user": {
    "id": "kimchy 1"
  },
  "text": "my favorite fruit is apple"
}
'
curl -X POST "localhost:9200/intervals_queries/_doc?pretty" -H 'Content-Type: application/json' -d'
{
  "user": {
    "id": "kimchy 2"
  },
  "text": "my favorite fruit is peach",
  "text1": "my favorite fruit is not peach",
  "text2": "my favorite fruit maybe peach"
}
'
curl -X POST "localhost:9200/intervals_queries/_doc?pretty" -H 'Content-Type: application/json' -d'
{
  "user": {
    "id": "kimchy 3"
  },
  "text": "my favorite drink is coffee"
}
'

# 用 match 匹配的示例
# 可以看到 peach my 匹配到了第二个文档，因为字段都出现了
curl -X GET "localhost:9200/intervals_queries/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "intervals": {
      "text": {
        "match" : { "query" : "peach my" }
      }
    }
  }
}
'
# max_gaps 定义文档之间最大跨度
# 如果设置 max_gaps 为 2，则不会匹配到第二文档了，如果设置为 3 则又能匹配到
curl -X GET "localhost:9200/intervals_queries/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "intervals": {
      "text": {
        "match" : { "query" : "peach my", "max_gaps": 2}
      }
    }
  }
}
'
# ordered 指定匹配的时候是否要按照 term 顺序进行匹配
# 如果设置 ordered 为 true，则 peach my 匹配不到第二个文档，要 my peach 才能匹配到
curl -X GET "localhost:9200/intervals_queries/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "intervals": {
      "text": {
        "match" : { "query" : "peach my", "ordered": true}
      }
    }
  }
}
'
# filter，match 可以指定 filter 规则进行进一步的筛选匹配，filter 放在后面讲, TODO 单开一个文档
# use_field，将匹配的字段变换成其他字段，比如下面的查询能匹配到第二个文档，如果改成 peach maybe 就匹配不到了，说明是按 text1 字段值进行的匹配
curl -X GET "localhost:9200/intervals_queries/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "intervals": {
      "text2": {
        "match" : { "query" : "peach is", "use_field": "text1"}
      }
    }
  }
}
'

# 用 prefix 匹配前缀 pea，可以看到第二个文档命中了，因为匹配到了 peach
# prefix 也可以用 use_field，同上
curl -X GET "localhost:9200/intervals_queries/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "intervals": {
      "text": {
        "prefix" : {
          "prefix" : "pea"
        }
      }
    }
  }
}
'

# 用 wildcard 进行通配符匹配，匹配 p?a*，可以看到也是只有第二个文档命中，因为 p?a*
# wildcard 也可以用 use_field，同上
curl -X GET "localhost:9200/intervals_queries/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "intervals": {
      "text": {
        "wildcard" : {
          "pattern" : "p?a*"
        }
      }
    }
  }
}
'

# 用 fuzzy 进行模糊匹配，匹配 peath，同样只匹配到第二个文档
# 可选参数
#    - prefix_length 指定前缀长度,要求必须前几个字符是不变的，如果下面的查询指定前缀长度为 4，就匹配不到了
#    - transpositions 是否将相邻位置字符互换算一次编辑距离，会影响最终的算法选择 TODO 单开一个文档
#    - fuzziness 定义允许的最大修改距离 TODO 单开一个文档
#    - use_field，同上
curl -X GET "localhost:9200/intervals_queries/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "intervals": {
      "text": {
        "fuzzy" : {
          "term" : "peath"
        }
      }
    }
  }
}
'

# 用 all_of 匹配的示例
# 下面的搜索会搜索到第二个文档，如果把 match 的 query 改成 asd，匹配不到后就搜索不到了
# 可选参数
#   - max_gaps，可以定义最大 gaps，超过这个 gaps 就匹配不到了，可以试着改下面的查询构造让它查不到文档
#   - ordered，是否按照顺序进行匹配，下面的查询如果指定 true，就查不到任何文档了
#   - filter，同 match，下面用了 filter 搜索，如果把 filter 的 query 改成 not，前面的文档就会被排除
curl -X GET "localhost:9200/intervals_queries/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "intervals": {
      "text1": {
        "all_of": {
          "intervals": [
            { "fuzzy" : { "term" : "peath" } },
            { "match" : { "query" : "is" } }
          ],
          "filter" : {
            "not_containing" : {
              "match" : {
                "query" : "123"
              }
            }
          }
        }
      }
    }
  }
}
'

# 用 any_of 匹配的示例
#   - filter，同 match
curl -X GET "localhost:9200/intervals_queries/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "intervals": {
      "text": {
        "any_of": {
          "intervals": [
            { "match" : { "query" : "is apple" } },
            { "match" : { "query" : "is peach" } }
          ]
        }
      }
    }
  }
}
'
