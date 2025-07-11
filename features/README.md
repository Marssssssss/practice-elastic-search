## feature 命名规则

1. 在每一个 feature 目录前面都会有一个用 '[]' 标注的标签，用以表明分类
2. 每种分类表明不同的含义
   1. Basic - 基本操作和概念，比如简单的增删改查姿势或者某些语言的 api 等等
   2. Benchmark - 一些基准测试，比如某些场景下的不同方案之间的性能比较
   3. Deploy - 部署相关的内容
   4. Advance - 深入研究的东西，比如文档的底层实现，一些搜索算法的底层实现等等

根据标签和标题即可大致了解这个 feature 主要讲的啥。

## 食用方法

1. 有空可以选择性地选择一个 feature 对照文档进行学习，配合实践内容记录在对应 feature 块里
2. 已经通过其它途径实践过的内容可以直接复现 case 并记录

## feature 大类列表

- [Basic]Interact_by_curl -> 通过 curl 和 elasticsearch 交互的例子，最基本的 linux es 交互手段，实践的基础
- [Basic]Index -> 索引层面的特性
- [Basic]Language_driver -> 各个语言的 elasticsearch 驱动
- [Basic]Mapping -> index 字段 mapping 相关的内容
- [Basic]Query -> 查询相关的内容，记录各种各样查询文档的方法
- [Benchmark]Index -> 索引层面的一些基准测试
