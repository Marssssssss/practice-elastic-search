# phrase match 用来匹配短语
# 支持一个参数 slop
#   - slop 等于要构造出查询短语移动词的最小步数，比如 a b c 要匹配 a c，则至少移动 1 次 a 或者 c，slop >= 1 才能匹配到，slop 默认为 0

# 创建文档
curl -X POST "localhost:9200/match_phrase_query/_doc?pretty" -H "Content-Type: application/json" -d'
{
  "user": {
    "id": "kimchy 1"
  },
  "text": "my favorite fruit is apple"
}
'
curl -X POST "localhost:9200/match_phrase_query/_doc?pretty" -H "Content-Type: application/json" -d'
{
  "user": {
    "id": "kimchy 3"
  },
  "text": "my favorite fruit is appl"
}
'
curl -X POST "localhost:9200/match_phrase_query/_doc?pretty" -H "Content-Type: application/json" -d'
{
  "user": {
    "id": "kimchy 2"
  },
  "text": "your favorite fruit is peach"
}
'

# 基本 match phrase 查询
curl -X GET "localhost:9200/match_phrase_query/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match_phrase": {
      "text": "is apple"
    }
  }
}
'

# 设置短语长度 slop
# 先设置 slop 为 1 匹配 my fruit，正好中间隔一个词，可以匹配到
# 设置 slop 为 1 匹配 my is，my 和 is 中间隔两个词大于 slop，匹配不到
# 设置 slop 为 4 匹配 is my，is 可以移动四次到 my 后面，4 == slop，所以可以匹配到，如果设置小于 4 就匹配不到了
# 设置 slop 为 2 匹配 my fruit apple，my 可以移动一次到 fruit 左边，apple 可以移动一次到 fruit 右边，1 + 1 = 2 == slop，所以可以匹配到，如果设置成 1 就匹配不到了
curl -X GET "localhost:9200/match_phrase_query/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match_phrase": {
      "text": {
        "query": "my fruit",
        "slop": 1
      }
    }
  }
}
'
curl -X GET "localhost:9200/match_phrase_query/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match_phrase": {
      "text": {
        "query": "my is",
        "slop": 2
      }
    }
  }
}
'
curl -X GET "localhost:9200/match_phrase_query/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match_phrase": {
      "text": {
        "query": "is my",
        "slop": 4
      }
    }
  }
}
'
curl -X GET "localhost:9200/match_phrase_query/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match_phrase": {
      "text": {
        "query": "my fruit apple",
        "slop": 2
      }
    }
  }
}
'
