# Docker HDFS Spark
This repository is just for learning how to deploy a Spark cluster with HDFS.

# Reference
## Hadoop
* Official
  * [Single Node Deployment](https://hadoop.apache.org/docs/r3.1.2/hadoop-project-dist/hadoop-common/SingleCluster.html)
    * You should read this document for the first time.
  * [Multi Node Deployment](https://hadoop.apache.org/docs/r3.1.2/hadoop-project-dist/hadoop-common/ClusterSetup.html)
    * And then, you should read this.

The docs about cluster setup are a bit complex, so to understand the whole picture, you should read the following:
* https://github.com/Marcel-Jan/docker-hadoop-spark
* https://medium.com/codex/running-a-multi-node-hadoop-cluster-257068e5f276

## Spark
In this repository, we use "Standalone" mode for Spark.

* Official
  * [Deply overview](https://spark.apache.org/docs/latest/cluster-overview.html)
  * [Standalone Mode](https://spark.apache.org/docs/latest/spark-standalone.html)
  * [Other configs](https://spark.apache.org/docs/latest/configuration.html)

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

## 4. open web console

* 1. if you're working on the remote machine, you should port forward the port 4444 and 7900 to your local machine, to access the web console.
* 2. then, open your browser and access `http://localhost:7900`
* 3. enter the password `password` and login noVNC.
* 4. click left mouse button and select "Applications" -> "Network" -> "Web Browsing" -> "Google Chrome"
* 5. open those links below:
  * `http://master:8080` (Spark Master)
  * `http://master:8088` (Yarn Resource Manager)
  * `http://master:9870` (HDFS NameNode)

# Issues
* (Solved) Cannot launch YARN resourcemanager / nodemanager
  * That's because we've used java 17 as runtime, though the hadoop 3.4.1 requires java 8 or 11.[ref](https://cwiki.apache.org/confluence/display/HADOOP/Hadoop+Java+Versions)
  * We decided to use java 11 for hadoop, and java 17 for spark (because we want to use the latest version of spark). I believe this works because spark only connect to hdfs through hdfs protocol?

* Write a script to gracefully stop the cluster.
