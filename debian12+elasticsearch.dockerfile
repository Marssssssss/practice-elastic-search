FROM debian:12

# 安装环境
RUN apt-get update
RUN apt-get install -y curl vim procps sudo net-tools

# 创建 elasticsearch 用户
RUN useradd -m -g sudo -s /bin/bash elasticsearch
USER elasticsearch

# 下载解压 es
WORKDIR /home/elasticsearch
RUN curl -L -O https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.11.1-linux-x86_64.tar.gz
RUN tar -xvf elasticsearch-7.11.1-linux-x86_64.tar.gz
RUN rm elasticsearch-7.11.1-linux-x86_64.tar.gz

# 构造启动脚本并启动 es
WORKDIR /home/elasticsearch
RUN echo "#!/bin/bash" >> start_es.sh
RUN echo "nohup /home/elasticsearch/elasticsearch-7.11.1/bin/elasticsearch &" >> start_es.sh
RUN chmod +x start_es.sh

# 构造容器启动脚本
RUN echo "#!/bin/bash" >> entrypoint.sh
RUN echo "nohup /bin/bash /home/elasticsearch/start_es.sh > /dev/null &" >> entrypoint.sh
RUN echo "echo \"Starting bash....\"" >> entrypoint.sh
RUN echo "/bin/bash" >> entrypoint.sh
RUN chmod +x entrypoint.sh

# 切换执行脚本到 es 目录下
WORKDIR /home/elasticsearch
COPY ./features ./features

# 开放端口
EXPOSE 9200
EXPOSE 9300

ENTRYPOINT ["/home/elasticsearch/entrypoint.sh"]
