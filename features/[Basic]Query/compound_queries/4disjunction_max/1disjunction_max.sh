# disjunction_max 查询列举出多个匹配项，并将其中匹配到分值最高的分值作为匹配的最终分值
#  - queries 匹配项列表
#  - tie_breaker （可选）如果查询不希望抛弃其他匹配项的分值，可以用这个字段定义加权值
#                 假如有三个匹配项 a、b、c，a 得分最高，那么最终的分数为 a + tie_breaker * (b + c)

# 创建文档
curl -X POST "localhost:9200/disjunction_max/_doc?pretty" -H "Content-Type: application/json" -d'
{
  "user": {
    "id": "kimchy 1"
  },
  "age": 15,
  "tags": "production"
}
'
curl -X POST "localhost:9200/disjunction_max/_doc?pretty" -H "Content-Type: application/json" -d'
{
  "user": {
    "id": "kimchy 1"
  },
  "age": 15,
  "tags": "env"
}
'

# 进行 disjunction_max 查询
# 可以看到第一个文档里 user.id 匹配的得分是 0.18232156，而 tags 的得分则是 0.6931471 (可以改命令试一下）
# 所以最终的得分是两个匹配项得分取 max = 0.6931471
curl -X GET "localhost:9200/disjunction_max/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "dis_max": {
      "queries": [
        { "term": { "user.id": "kimchy" } },
        { "term": { "tags": "production" } }
      ]
    }
  }
}
'

# 尝试加上 tie_breaker，看匹配的结果是啥
# 可以看到分值变成了 user.id 匹配的评分 * 0.7 + tags 匹配的评分了
curl -X GET "localhost:9200/disjunction_max/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "dis_max": {
      "queries": [
        { "term": { "user.id": "kimchy" } },
        { "term": { "tags": "production" } }
      ],
      "tie_breaker": 0.7
    }
  }
}
'
