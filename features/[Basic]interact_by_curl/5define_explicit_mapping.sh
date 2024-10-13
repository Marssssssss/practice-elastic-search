# PUT /my-explicit-mappings-books
# 显式定义索引包含的字段，方便管理和维护
# dynamic 设置成 false，这样就关闭了动态 mapping
# properties 来设置各个字段的类型
curl -X PUT "localhost:9200/my-explicit-mappings-books?pretty" -H 'Content-Type: application/json' -d'
{
  "mappings": {
    "dynamic": false,
    "properties": {
      "name": { "type": "text" },
      "author": { "type": "text" },
      "release_date": { "type": "date", "format": "yyyy-MM-dd" },
      "page_count": { "type": "integer" }
    }
  }
}
'

# 尝试添加一个不符合要求的文档会成功
curl -X POST "localhost:9200/my-explicit-mappings-books/_doc?pretty" -H 'Content-Type: application/json' -d'
{
  "name": "The Great Gatsby",
  "author": "F. Scott Fitzgerald",
  "release_date": "1925-04-10",
  "page_count": 180,
  "language": "EN"
}
'

# match 搜索 language 字段，会发现搜不到，说明虽然上面字段包含 language，实际并没有写入
curl -X GET "localhost:9200/my-explicit-mappings-books/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match": {
      "language": "EN"
    }
  }
}
'
