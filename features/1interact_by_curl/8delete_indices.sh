# DELETE /books
# DELETE /my-explicit-mappings-books
# 删除索引
curl -X DELETE "localhost:9200/books?pretty"
curl -X DELETE "localhost:9200/my-explicit-mappings-books?pretty"
