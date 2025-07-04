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

# Issues
* (Solved) Cannot launch YARN resourcemanager / nodemanager
  * That's because we use java 17 as runtime, though the hadoop 3.4.1 requires java 8 or 11.
  * We decided to use java 11 for hadoop, and java 17 for spark.

