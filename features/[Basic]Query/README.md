## 基本查询上下文
elasticsearch 的查询分为两种

- query 适用于相关性查询并排序，会进行算分，无法缓存，效率较低
- filter 适用于直接查询匹配文档，不会算分，会进行缓存，效率较高

这两种语义不是单纯某一层，比如 bool 下的 must 是 query，但是 filter 和 must_not 则是 filter。


## 复合查询上下文 Compound Query
es 在最基本的文本/数字匹配规则上提供了更多层控制，从而实现更灵活的查询功能，包含几种：

- boolean 查询，可以实现简单的与或非逻辑组合，和匹配个数等功能
- boosting 查询，可以自定义统计分权重的查询
- constant_score 查询，给 filter 上下文匹配赋予分值权重的查询
- disjunction_max 查询，类似于 max 函数，在多个匹配项中选取分值最高的一项对分值进行赋值
- function_score 查询，可以自定义对查询后文档的评分处理，以及评分后的筛选，规则比较灵活


## 全文搜索 Full Text Queries
全文搜索提供一系列规则进行文字搜索。

- intervals 查询，主要是组合各种文本片段匹配的规则来匹配某个字段下的一段文本
- match 查询，利用分词器 analyzer 分词匹配，支持模糊匹配和分词逻辑匹配
- match_bool_prefix 查询语法糖，将 term + term + ... + term + prefix 的 bool 查询合并到一个字符串里的查询
- match_phrase 查询，对短语进行查询，也就是对连续的 term 串进行查询，能用参数支持更灵活的有间隔情况的匹配
- match_phrase_prefix 查询语法糖，匹配 "term term ... term prefix" 这种形式的分词串，类似 match_bool_prefix 和 match_phrase 的结合
- combined_fields 查询，同时对多个字段进行同一个 query 的 match 查询，其中一个匹配即匹配文档
- multi_match 查询，同时对多个字段进行同一个 query 的查询，能够指定查询类型，支持 match_bool_prefix 等查询类型
- query_string 查询，用一段字符串来描述查询规则，支持正则表达式，能支撑复杂的字段匹配和值匹配
- simple_query_string 查询，和 query_string 类似，区别在于字符串表达规则更简单，但不支持正则表达式等匹配规则


## 基于地理位置的查询 Geo Queries
地理位置查询提供一系列基于 geo_xxx 系列数据结构的查询，用来支持对地理位置的查询，地理位置点在一个二维空间里进行描述

- geo_bounding_box 查询，通过指定一个矩形范围来匹配 geo_point 或者 geo_shape 和这个矩形相交的文档
- geo_distance 查询，通过指定一个 geo_point 匹配离这个 point 指定距离内的其他 geo_point 或者 geo_shape
- geo_grid 查询，粗看文档和 geo_hash 有关，TODO 细看下
- geo_polygon 查询，匹配 geo_point 类型的字段落在一个多边形范围的文档
- geo_shape 查询，TODO 细看下


## 基于形状的查询
形状查询提供基于 shape 数据类型字段的查询

- shape 查询，可以用指定形状和对文档形状的关系（相交、包含等）来匹配文档
- indexed_shape 查询，TODO 细看下


## Match All 查询
最简单的查询，返回一个 index 里的所有文档


## Term-level 查询
词项级别的精确查询，应该算是比较常用的查询了

- exists 查询，查询某个字段是否存在
- fuzzy 查询，模糊查询一个字段值，基于 Levenshtein 距离算法
- ids 查询，直接用 _id 字段进行匹配
- prefix 查询，前缀查询，字段包含指定前缀
- range 查询，字段值在某个范围内的文档将会被查询
- regexp 查询，用正则字符串匹配文档的字段
- term 查询，精确查询一段字符串，查询的字符串不会被分词
- terms 查询，精确查询几段字符串，都匹配到的文档才会被返回
- terms_set 查询，在 terms 基础上能够指定最小匹配数量的规则
- wildcard 查询，支持通配符指定字段值进行查询


## 其它内容
- specify_source_fields -> 查询可以通过 _source 字段来指定查询到的文档返回哪些字段


## TODO
- Joining Queries
- Match All
- Span Queries
- Vector Queries
- Specialized Queries
