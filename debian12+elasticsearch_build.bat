docker build --no-cache -t="env_elasticsearch:latest" -f debian12+elasticsearch.dockerfile .
docker rm -f elasticsearch
docker run -itd --name="elasticsearch" env_elasticsearch:latest
@pause
