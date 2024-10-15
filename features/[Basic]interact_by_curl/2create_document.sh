# POST books/_doc
# 在 books 里面添加一个文档
# 在不定义 dynamic_mapping 的情况下，添加的第一个文档会决定每个字段的类型
curl -X POST "localhost:9200/books/_doc?pretty" -H 'Content-Type: application/json' -d'
{
  "name": "Snow Crash",
  "author": "Neal Stephenson",
  "release_date": "1992-06-01",
  "page_count": 470
}
'

# 这里示例 curl 的文件传递 body 方法
#cat >> body.json << EOF
#{
#  "name": "Snow Crash",
#  "author": "Neal Stephenson",
#  "release_date": "1992-06-01",
#  "page_count": 470
#}
#EOF
#
#curl -H 'content-Type:application/json' -XPOST 'http://127.0.0.1:9200/books/_doc' -d@body.json
#
#rm body.json

