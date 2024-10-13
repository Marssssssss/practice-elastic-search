# 在 bool 的几种匹配条件里，可以指定 _name 来指明是那个匹配命中了
# TODO：term 这个字段不支持 query，回头再研究下 =。=

# 添加文档
curl -X POST "localhost:9200/track_match_by_name/_doc?pretty" -H 'Content-Type: application/json' -d'
{
  "user": {
    "id": "kimchy 1"
  },
  "age": 15,
  "tags": "production"
}
'
curl -X POST "localhost:9200/track_match_by_name/_doc?pretty" -H 'Content-Type: application/json' -d'
{
  "user": {
    "id": "amy"
  },
  "age": 15,
  "tags": "env"
}
'
curl -X POST "localhost:9200/track_match_by_name/_doc?pretty" -H 'Content-Type: application/json' -d'
{
  "user": {
    "id": "kimchy"
  },
  "age": 15,
  "tags": "env"
}
'

# 尝试用 should 去匹配文档
# 在三个匹配到的文档结果里会多一个 matched_queries 字段，这个字段用 array 的形式存了命中的 _name
curl -X POST "localhost:9200/track_match_by_name/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool" : {
      "should" : [
        { "match" : { "user.id" : { "query": "kimchy", "_name": "by_id"} } },
        { "match" : { "tags" : { "query": "env" , "_name": "by_tag"} } }
      ]
    }
  }
}
'

