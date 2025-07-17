#!/bin/bash

{
echo "export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64" 
echo "export PYSPARK_PYTHON=/usr/bin/python3" 
echo "export SPARK_MASTER_HOST=master" 
echo "export SPARK_LOCAL_DIRS=/data/spark/local" 
echo "export SPARK_LOG_DIR=/data/spark/logs" 
echo "export SPARK_PID_DIR=/data/spark/pid" 
echo "export SPARK_WORKER_DIR=/data/spark/work"
echo "export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop"
echo "export SPARK_MASTER_WEBUI_PORT=8080"
} >> /opt/spark/conf/spark-env.sh

{
  echo "spark.eventLog.enabled true"
  echo "spark.eventLog.dir hdfs://master:9000/shared/spark-logs"
  echo "spark.history.fs.logDirectory hdfs://master:9000/shared/spark-logs"
  echo "spark.history.ui.port 18080"
} >> /opt/spark/conf/spark-defaults.conf

{
  echo "master"
  echo "worker1"
  echo "worker2"
} >> /opt/spark/conf/workers

if [ "$(hostname)" == "master" ]; then
    # start spark cluster
    /opt/spark/sbin/start-all.sh
    # create hdfs directory
    hdfs dfs -mkdir -p /shared/spark-logs
    # start history server
    /opt/spark/sbin/start-history-server.sh
fi
