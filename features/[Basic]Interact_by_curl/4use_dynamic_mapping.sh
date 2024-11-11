# GET /books/_mapping
# es 默认给文档创建了 dynamic mapping，可以直接查询
# 查询的结果就是 index 里面创建的文档的所有字段的类型等元数据
curl -X GET "localhost:9200/books/_mapping?pretty"

# 加一个更多字段的文档
curl -X POST "localhost:9200/books/_doc?pretty" -H 'Content-Type: application/json' -d'
{
  "name": "The Great Gatsby",
  "author": "F. Scott Fitzgerald",
  "release_date": "1925-04-10",
  "page_count": 180,
  "language": "EN"
}
'

# 再查一次就能看到 mapping 里的字段变多了
curl -X GET "localhost:9200/books/_mapping?pretty"
