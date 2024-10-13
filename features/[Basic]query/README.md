## 基本查询上下文
elasticsearch 的查询分为两种

- query 适用于相关性查询并排序，会进行算分，无法缓存，效率较低
- filter 适用于直接查询匹配文档，不会算分，会进行缓存，效率较高

这两种语义不是单纯某一层，比如 bool 下的 must 是 query，但是 filter 和 must_not 则是 filter。


## 复合查询上下文 Compound Query
各种类型的查询可以利用 elasticsearch 提供的 dsl 进行逻辑组合，从而实现一些比较复杂的查询。

包含几种：

- boolean 查询，可以实现简单的与或非逻辑组合，和匹配个数等功能
- boosting 查询，可以自定义统计分权重的查询
- constant_score 查询，给 filter 上下文匹配赋予分值权重的查询