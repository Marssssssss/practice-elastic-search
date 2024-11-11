# script_score 函数
# 允许直接通过脚本利用 doc 的内容进行评分

# 创建文档
curl -X POST "localhost:9200/function_score_script_score/_doc?pretty" -H "Content-Type: application/json" -d'
{
  "user": {
    "id": "kimchy 1"
  },
  "age": 15,
  "tags": "production"
}
'

# 通过 script_score 对 age 进行计算
# 脚本内容放在 script.source 下
# 这里对 age 做了一个取对数的运算
curl -X GET "localhost:9200/function_score_script_score/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "function_score": {
      "query": { "match_all": {} },
      "script_score": {
        "script": {
          "source": "Math.log(2 + doc[\"age\"].value)"
        }
      }
    }
  }
}
'

# 带 params 的计算
# 可以看到定义的 params 被传递到了 source 里面参与了计算
curl -X GET "localhost:9200/function_score_script_score/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "function_score": {
      "query": { "match_all": {} },
      "script_score": {
        "script": {
          "params": {
            "a": 5,
            "b": 1.2
          },
          "source": "params.a / Math.pow(params.b, doc[\"age\"].value)"
        }
      }
    }
  }
}
'
