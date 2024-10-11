# POST books/_doc
# 在 books 里面添加一个文档
# 这里用到了 curl 的文件传递 body 方法
cat >> body.json << EOF
{
  "name": "Snow Crash",
  "author": "Neal Stephenson",
  "release_date": "1992-06-01",
  "page_count": 470
}
EOF

curl -H 'content-Type:application/json' -XPOST 'http://127.0.0.1:9200/books/_doc' -d@body.json

rm body.json