# bool 查询包含
#   must 与的逻辑
#   should 或的逻辑
#   must_not 非的逻辑
#   filter 类似与，和 must 的区别就在于它是 filter 语义，不计分

# 添加几个文档
curl -X POST "localhost:9200/bool_queries/_doc?pretty" -H 'Content-Type: application/json' -d'
{
  "user": {
    "id": "kimchy 1"
  },
  "age": 15,
  "tags": "production"
}
'
curl -X POST "localhost:9200/bool_queries/_doc?pretty" -H 'Content-Type: application/json' -d'
{
  "user": {
    "id": "kimchy 2"
  },
  "age": 21,
  "tags": "production"
}
'
curl -X POST "localhost:9200/bool_queries/_doc?pretty" -H 'Content-Type: application/json' -d'
{
  "user": {
    "id": "kimchy 3"
  },
  "age": 21,
  "tags": "env1"
}
'
curl -X POST "localhost:9200/bool_queries/_doc?pretty" -H 'Content-Type: application/json' -d'
{
  "user": {
    "id": "kimchy 3"
  },
  "age": 21,
  "tags": "production env1"
}
'


# 进行复合筛选，bool 本身是与的逻辑
# 可以看到上面添加的文档中有两个符合条件的被筛选出来了
# 可以看着结果理解下每个词条的作用
#   - 第一条因为年龄项在范围内被 must_not 剔除了
#   - 第三条因为 tags 不包含 production 字段被 filter 剔除了
curl -X GET "localhost:9200/bool_queries/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool" : {
      "must" : {
        "term" : { "user.id" : "kimchy" }
      },
      "filter": {
        "term" : { "tags" : "production" }
      },
      "must_not" : {
        "range" : {
          "age" : { "gte" : 10, "lte" : 20 }
        }
      },
      "should" : [
        { "term" : { "tags" : "env1" } },
        { "term" : { "tags" : "deployed" } }
      ]
    }
  }
}
'
