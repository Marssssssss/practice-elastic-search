## 基本查询上下文
elasticsearch 的查询分为两种

- query 适用于相关性查询并排序，会进行算分，无法缓存，效率较低
- filter 适用于直接查询匹配文档，不会算分，会进行缓存，效率较高

这两种语义不是单纯某一层，比如 bool 下的 must 是 query，但是 filter 和 must_not 则是 filter。


## 复合查询上下文 Compound Query
查询操作就是从 index 里面筛选出想要的文档， 最基本的匹配逻辑就是文本字段的匹配吗，比如从 "aaa bbb" 中匹配到 aaa 这个词之类的。

es 在最基本的文本/数字匹配规则上提供了更多层控制，从而实现更灵活的查询功能，包含几种：

- boolean 查询，可以实现简单的与或非逻辑组合，和匹配个数等功能
- boosting 查询，可以自定义统计分权重的查询
- constant_score 查询，给 filter 上下文匹配赋予分值权重的查询
- disjunction_max 查询，类似于 max 函数，在多个匹配项中选取分值最高的一项对分值进行赋值
- function_score 查询，可以自定义对查询后文档的评分处理，以及评分后的筛选，规则比较灵活