# boost 字段用于提升某个查询的权重，计算逻辑是 score * boost
# TODO term 不支持 query 字段，会报错，回头再研究下是不是还有什么遗漏

# 添加文档
curl -X POST "localhost:9200/boost/_doc?pretty" -H 'Content-Type: application/json' -d'
{
  "user": {
    "id": "kimchy 1"
  },
  "age": 15,
  "tags": "production"
}
'
curl -X POST "localhost:9200/boost/_doc?pretty" -H 'Content-Type: application/json' -d'
{
  "user": {
    "id": "amy"
  },
  "age": 15,
  "tags": "env"
}
'
curl -X POST "localhost:9200/boost/_doc?pretty" -H 'Content-Type: application/json' -d'
{
  "user": {
    "id": "kimchy"
  },
  "age": 15,
  "tags": "env"
}
'

# 先无权重查询一下
# 权重分别为 0.99355197 0.4700036 0.39019167
curl -X POST "localhost:9200/boost/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool" : {
      "should" : [
        { "match" : { "user.id" : "kimchy" } },
        { "match" : { "tags" : "env" } }
      ]
    }
  }
}
'

# 为不同的条件指定不同的权重
# 可以看到权重一定程度上提升了
# 权重分别为 2.4571075 1.4100108 0.78038335
# 观察权重可以发现似乎只是简单的一个乘法，复合多条件匹配的情况估计是加权后再复合计算的
curl -X POST "localhost:9200/boost/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool" : {
      "should" : [
        { "match" : { "user.id" : { "query": "kimchy", "boost": 2.0} } },
        { "match" : { "tags" : { "query": "env" , "boost": 3.0} } }
      ]
    }
  }
}
'
