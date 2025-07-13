#!/bin/bash

{
echo "export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64" 
echo "export PYSPARK_PYTHON=/usr/bin/python3" 
echo "export SPARK_MASTER_HOST=master" 
echo "export SPARK_LOCAL_DIRS=/data/spark/local" 
echo "export SPARK_LOG_DIR=/data/spark/logs" 
echo "export SPARK_PID_DIR=/data/spark/pid" 
echo "export SPARK_WORKER_DIR=/data/spark/work" 
echo "export SPARK_WORKER_WEBUI_PORT=18080"
echo "export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop"
} >> /opt/spark/conf/spark-env.sh

{
  echo "master"
  echo "worker1"
  echo "worker2"
} >> /opt/spark/conf/workers

if [ "$(hostname)" == "master" ]; then
    # start spark cluster
    /opt/spark/sbin/start-all.sh
fi
