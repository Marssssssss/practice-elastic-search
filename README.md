## 通过 docker 搭建本地环境

1. 确保本地有 docker
2. 执行 debian12+elasticsearch_build.bat
3. 执行好后可以使用 debian12+elasticsearch_bash.bat 进入容器操作
4. 可以使用 2 的脚本重新构建容器

在容器 /home/elasticsearch/features 下可以查看 features 文件下的脚本，功能点都列在目录下的 sh 脚本里。
一般情况下不推荐直接跑脚本，建议根据 sh 脚本里的注释逐个执行来理解功能点。

每个 case 的理解基本都放在脚本的注释里或者 README.md 里，直接翻阅即可

# 版本
本 practice 基于 elasticsearch 8.15 版本

# TODO
重新整理各个子目录结构：

- 更适合分子目录的进一步切分
- 如果内容比较多的子目录补上一个文档方便索引，理论上从顶层到底层需要有一个合理的逻辑分层
