# Docker HDFS Spark
This repository is just for learning how to deploy a Spark cluster with HDFS.

# Reference
* https://github.com/Marcel-Jan/docker-hadoop-spark
* https://medium.com/codex/running-a-multi-node-hadoop-cluster-257068e5f276

# How to run
## 1. build container
```bash
docker compose build
```

## 2. start cluster
```bash
docker compose up -d
```

## 3. login to master node
```bash
docker exec -it master bash
```

# TODO
* Cannot launch YARN resourcemanager / nodemanager
