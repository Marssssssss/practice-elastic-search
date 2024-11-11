# index 字段的特性

## Dynamic mapping 动态映射特性

### dynamic field mapping 动态字段映射
1. mapping.dynamic 指定为 true 或者 runtime 的时候，如果字段没有定义则添加文档的时候会自动根据字段值类型动态定义字段类型
2. true 和 runtime 的行为对于 array、string 略有不同

### dynamic templates 
动态模板用来定义字段动态指定类型时的行为，可以实现某些模式的字段名字（比如 long_*）默认为 long 类型这种规则，将 es 原本想动态设置成 a
类型的字段通过规则判断映射到 b 类型种类规则


## Explicit mapping 显式映射
和动态映射不同，index 支持显式映射字段类型

1. 创建时显式映射
2. 后续显式新增/更新映射
