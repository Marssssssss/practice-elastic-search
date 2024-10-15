# decay 构造了一个从某一个值开始向外逐渐衰减分值的 function
# 具体图形和分析可以参照文档 https://www.elastic.co/guide/en/elasticsearch/reference/8.15/query-dsl-function-score-query.html#function-field-value-factor
# decay function 的名字就是函数名，有三种：
#   - linear 线性
#   - gauss 高斯分布/正态分布
#   - exp 指数分布
# 分量：
#   - origin 中心值，从中心值开始，字段值和中心差值的绝对值越大，分值越小
#   - offset 衰减的偏移值，决定衰减开始的值是多少
#     - 比如中心值 5，offset 为 0 时，字段值不等于 5 就开始衰减了
#     - 而 offset 为 1 时，字段值要小于 4 或者大于 6 才开始衰减，4 到 6 范围内都是 1.0
#   - scale 和 decay 字段一起配置，指定衰减到 decay 值的时候，字段值距离衰减开始的值有多远
#   - decay 和 scale 字段一起配置，指定衰减到 scale 位置时分值为多少

# 可以使用 multi_value_mode 去指定字段包含多个值的情况下怎么聚合每个值的结果
#   - distance 计算公式 | fieldvalue - origin | - offset
#   - distance 在 [origin - offset, origin + offset] 范围内都是 0
#   - 最终的距离计算公式为 multi_value_mode(distance1, distance2...)，其中 distancei 是第 i 个值的 distance
#   - 最终的 distance 再参与衰减计算

# 字段类型只支持 numeric、date 和 geopoint
# 字段不存在的话，函数返回都是 1

# 创建文档
curl -X POST "localhost:9200/function_score_decay_function/_doc?pretty" -H "Content-Type: application/json" -d'
{
  "user": {
    "id": "kimchy 1"
  },
  "age": 15.0,
  "tags": "production"
}
'

# 尝试线性衰减
curl -X GET "localhost:9200/function_score_decay_function/_search?pretty" -H "Content-Type: application/json" -d'
{
  "query": {
    "function_score": {
      "linear": {
        "age": {
          "origin": "10",
          "scale": 10,
          "offset": "0",
          "decay": 0.33
        }
      },
      "boost_mode": "replace"
    }
  }
}
'

# 设置 origin 为 13， offset 为 0，此时 age 距离中心值为 2
# 如果设置 decay 为 0.33，scale 为 | age - origin + offset |（也就是说目前 age 正好落在 decay 分值上，为 0.33）
curl -X GET "localhost:9200/function_score_decay_function/_search?pretty" -H "Content-Type: application/json" -d'
{
  "query": {
    "function_score": {
      "linear": {
        "age": {
          "origin": "13",
          "scale": 2,
          "offset": "0",
          "decay": 0.33
        }
      },
      "boost_mode": "replace"
    }
  }
}
'
# 再试着设置 scale 为 | age - origin + offset | - 1 （也就是说字段值比 scale 还要远 1）
# 按照线性的衰减，分值到 14.49 差不多的时候就已经归零了，因此下面的分值结果应该为 0
curl -X GET "localhost:9200/function_score_decay_function/_search?pretty" -H "Content-Type: application/json" -d'
{
  "query": {
    "function_score": {
      "linear": {
        "age": {
          "origin": "13",
          "scale": 1,
          "offset": "0",
          "decay": 0.33
        }
      },
      "boost_mode": "replace"
    }
  }
}
'
# 如果设置 offset 为 3 覆盖到了 age = 15，那么查询结果为 1
curl -X GET "localhost:9200/function_score_decay_function/_search?pretty" -H "Content-Type: application/json" -d'
{
  "query": {
    "function_score": {
      "linear": {
        "age": {
          "origin": "13",
          "scale": 1,
          "offset": "3",
          "decay": 0.33
        }
      },
      "boost_mode": "replace"
    }
  }
}
'
# 把 offset 修改回 1，会发现现在差不多到 15.49 的时候才会归零，此时分值为 0.33（正好证明 scale 是 origin 加上 offset 后的偏移点）
curl -X GET "localhost:9200/function_score_decay_function/_search?pretty" -H "Content-Type: application/json" -d'
{
  "query": {
    "function_score": {
      "linear": {
        "age": {
          "origin": "13",
          "scale": 1,
          "offset": "1",
          "decay": 0.33
        }
      },
      "boost_mode": "replace"
    }
  }
}
'

# multi_value_mode 用于具有多个值的字段的计分
# distance 聚合有几种类型：
#   - min 取最小 distance
#   - max 取最大 distance
#   - avg 取平均 distance
#   - sum 所有 distance 相加
# 下面的例子用了 avg，最终 distance 为 (|15 - 14| + |14 - 14| + 0) / 3 = 0.33333333，等同于单个 age = 14.333333 进行计算
# 所以最终分值为 0.776669
curl -X POST "localhost:9200/function_score_decay_function/_doc?pretty" -H "Content-Type: application/json" -d'
{
  "user": {
    "id": "kimchy 1"
  },
  "age": [15.0, 14.0, 13.0],
  "tags": "production"
}
'
curl -X GET "localhost:9200/function_score_decay_function/_search?pretty" -H "Content-Type: application/json" -d'
{
  "query": {
    "function_score": {
      "linear": {
        "age": {
          "origin": "13",
          "scale": 1,
          "offset": "1",
          "decay": 0.33
        },
        "multi_value_mode": "avg"
      },
      "boost_mode": "replace"
    }
  }
}
'
