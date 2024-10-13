# minimum_should_match 字段用来过滤 bool 查询结果中 match 条目数量少于指定指标的文档
# 比如 should 查询里面有两个条件，指定 minimum_should_match 为 2，则只匹配到其中一个条件或者没匹配到的都会从最终结果中被剔除

# 构造文档
curl -X POST "localhost:9200/minimum_should_match/_doc?pretty" -H 'Content-Type: application/json' -d'
{
  "user": {
    "id": "kimchy 1"
  },
  "tags": "production"
}
'
curl -X POST "localhost:9200/minimum_should_match/_doc?pretty" -H 'Content-Type: application/json' -d'
{
  "user": {
    "id": "kimchy 2"
  },
  "tags": "production fake"
}
'
curl -X POST "localhost:9200/minimum_should_match/_doc?pretty" -H 'Content-Type: application/json' -d'
{
  "user": {
    "id": "kimchy"
  },
  "tags": "production"
}
'
curl -X POST "localhost:9200/minimum_should_match/_doc?pretty" -H 'Content-Type: application/json' -d'
{
  "user": {
    "id": "kimchy"
  },
  "tags": "env"
}
'
curl -X POST "localhost:9200/minimum_should_match/_doc?pretty" -H 'Content-Type: application/json' -d'
{
  "user": {
    "id": "kimchy"
  },
  "tags": "production",
  "cond": "true"
}
'

# 进行查询
# 可以看到所有文档都匹配到
curl -X POST "localhost:9200/minimum_should_match/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool" : {
      "should" : [
        { "term" : { "user.id" : "kimchy" } },
        { "term" : { "cond" : "true" } },
        { "term" : { "tags" : "production" } }
      ]
    }
  }
}
'

# Integer 指定 minimum_should_match 为 2
# 只有匹配到两个条件的文档留下来了（匹配到三个或者以上的也能留下
curl -X POST "localhost:9200/minimum_should_match/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool" : {
      "should" : [
        { "term" : { "user.id" : "kimchy" } },
        { "term" : { "cond" : "true" } },
        { "term" : { "tags" : "production" } }
      ],
      "minimum_should_match": 2
    }
  }
}
'

# Negative Integer 指定 minimum_should_match 为 -1，等效于最大条件数 -1，这里也即 2，等同于 minimum_should_match Integer 指定为 2
# 只有匹配到两个条件的文档留下来了（匹配到三个或者以上的也能留下）
curl -X POST "localhost:9200/minimum_should_match/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool" : {
      "should" : [
        { "term" : { "user.id" : "kimchy" } },
        { "term" : { "cond" : "true" } },
        { "term" : { "tags" : "production" } }
      ],
      "minimum_should_match": -1
    }
  }
}
'

# percentage 指定 minimum_should_match 为 70%，等效于最大条件数乘上这个百分比，结果向下取整，这里最终结果为 2
curl -X POST "localhost:9200/minimum_should_match/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool" : {
      "should" : [
        { "term" : { "user.id" : "kimchy" } },
        { "term" : { "cond" : "true" } },
        { "term" : { "tags" : "production" } }
      ],
      "minimum_should_match": "70%"
    }
  }
}
'

# Negative Percentage 指定 minimum_should_match 为 -25%，等效于最大条件数乘上（1 - 这个百分比），结果向上取整，这里计算结果为 3
# 所以最终只会有一条文档结果
curl -X POST "localhost:9200/minimum_should_match/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool" : {
      "should" : [
        { "term" : { "user.id" : "kimchy" } },
        { "term" : { "cond" : "true" } },
        { "term" : { "tags" : "production" } }
      ],
      "minimum_should_match": "-25%"
    }
  }
}
'

# Combination 指定为 3<90%，如果总条件数小于等于 3 就全部需要，否则视作用后面那个值来指定 minimum_should_match，这里最终结果是 3
curl -X POST "localhost:9200/minimum_should_match/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool" : {
      "should" : [
        { "term" : { "user.id" : "kimchy" } },
        { "term" : { "cond" : "true" } },
        { "term" : { "tags" : "production" } }
      ],
      "minimum_should_match": "3<90%"
    }
  }
}
'
# Case2 大于 2 则按 3 个条件匹配
curl -X POST "localhost:9200/minimum_should_match/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool" : {
      "should" : [
        { "term" : { "user.id" : "kimchy" } },
        { "term" : { "cond" : "true" } },
        { "term" : { "tags" : "production" } }
      ],
      "minimum_should_match": "2<3"
    }
  }
}
'

# Multiple Combination 指定多个分段条件
# 如果同时定义了类似于 2<1 2<2，则后面的覆盖前面的
# 定义的结果顺序无关，不影响分段的依据（排个序就行
# 像下面这种 case 就是
#   - 如果总条件数在 [0, 1] 区间，就按照条件数来指定 minimum_should_match
#   - 如果总条件数在 (1, 3] 区间，就按照 1<1 的不满足条件指定 minimum_should_match = 1
#   - 如果总条件数大于 3，就按照 3<90% 的不满足条件指定 minimum_should_match = 90%
curl -X POST "localhost:9200/minimum_should_match/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool" : {
      "should" : [
        { "term" : { "user.id" : "kimchy" } },
        { "term" : { "cond" : "true" } },
        { "term" : { "tags" : "production" } }
      ],
      "minimum_should_match": "1<1 3<90%"
    }
  }
}
'

