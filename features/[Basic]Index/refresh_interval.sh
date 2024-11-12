# elasticsearch 采用了文件系统缓存的机制来减轻磁盘存储压力
# 文档从更新到能够被查询查到需要先经过文件系统缓存，即 更新 -> 文件系统缓存 -> 可搜索文档，更新到文件系统缓存后要过一段时间才能被搜索到
# 所以刚更新文档就立刻搜索可能搜不到刚更新的内容

# 对于这个机制，elasticsearch 开了几个口子来控制并支持实时更新
#   1.index.refresh_interval 设置
#   2.http 接口 refresh，用于主动刷新

# TODO refresh 接口支持一些参数，可以进一步研究下

# 可以在创建索引的时候指定 refresh_interval 来指定这个索引的刷新间隔
# 设置值支持 ms、s 和 m 单位，分别代表毫秒、秒和分钟
curl -H 'content-Type:application/json' -XPUT 'http://127.0.0.1:9200/refresh_interval' -d'
{
  "settings": {
    "refresh_interval": "30s"
  }
}
'

# 创建文档
curl -X POST "localhost:9200/refresh_interval/_doc/1?pretty" -H "Content-Type: application/json" -d'
{
  "user": {
    "id": "kimchy 1"
  },
  "text": "my favorite fruit is apple"
}
'

# 尝试 upsert 先写，等 1s 再查询
# 使用 GET 直接拉取文档发现已经变了
# 使用 _search 发现搜索到的文档还是之前那个
curl -X POST "localhost:9200/refresh_interval/_update/1?pretty" -H 'Content-Type: application/json' -d'
{
  "doc": {
    "text": "Updated title"
  },
  "doc_as_upsert": true
}
'
sleep 1s
curl -X GET "localhost:9200/refresh_interval/_doc/1?pretty" -H 'Content-Type: application/json'
curl -X POST "localhost:9200/refresh_interval/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match": {
      "user.id": "kimchy"
    }
  }
}
'


# 重新设置刷新时间为 100ms 然后重复上述操作，这次立刻就刷上去了
curl -X PUT "localhost:9200/refresh_interval/_settings?pretty" -H 'Content-Type: application/json' -d'
{
  "index": {
    "refresh_interval": "100ms"
  }
}
'
curl -X POST "localhost:9200/refresh_interval/_update/1?pretty" -H 'Content-Type: application/json' -d'
{
  "doc": {
    "text": "Updated title2"
  },
  "doc_as_upsert": true
}
'
sleep 1
curl -X GET "localhost:9200/refresh_interval/_doc/1?pretty" -H 'Content-Type: application/json'
curl -X POST "localhost:9200/refresh_interval/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match": {
      "user.id": "kimchy"
    }
  }
}
'


# 再试试另一个口子 refresh
# 设置回 30s 然后更改文档，之后立刻执行
curl -X PUT "localhost:9200/refresh_interval/_settings?pretty" -H 'Content-Type: application/json' -d'
{
  "index": {
    "refresh_interval": "30s"
  }
}
'
curl -X POST "localhost:9200/refresh_interval/_update/1?pretty" -H 'Content-Type: application/json' -d'
{
  "doc": {
    "text": "Updated title3"
  },
  "doc_as_upsert": true
}
'
curl -X POST "localhost:9200/refresh_interval/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match": {
      "user.id": "kimchy"
    }
  }
}
'
curl -X POST "localhost:9200/refresh_interval/_refresh?pretty" -H 'Content-Type: application/json'
curl -X POST "localhost:9200/refresh_interval/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match": {
      "user.id": "kimchy"
    }
  }
}
'
