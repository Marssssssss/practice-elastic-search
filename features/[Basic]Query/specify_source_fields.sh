# 查询可以通过 _source 字段来指定查询到的文档返回哪些字段
# 创建文档
curl -X POST "localhost:9200/specify_source_fields/_doc?pretty" -H "Content-Type: application/json" -d'
{
  "user": {
    "id": "kimchy 1",
    "aaa": 2
  },
  "text": "my favorite fruit is apple"
}
'

# 进行一次查询
# 可以看到查询返回了所有字段
curl -X GET "localhost:9200/specify_source_fields/_search?pretty" -H 'Content-Type: application/json' -d'
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

# 指定返回字段进行查询，在返回文档 _source 里只保留 text
curl -X GET "localhost:9200/specify_source_fields/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "_source": ["text"],
  "query": {
    "match": {
      "text": {
        "query": "my fruit apple"
      }
    }
  }
}
'

# 支持嵌套指定，在返回文档 _source 里只保留 user.id 和 text
curl -X GET "localhost:9200/specify_source_fields/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "_source": ["user.id", "text"],
  "query": {
    "match": {
      "text": {
        "query": "my fruit apple"
      }
    }
  }
}
'
