#!/bin/sh

HADOOP_HOME=/opt/hadoop
SPARK_HOME=/opt/spark

echo "Stopping Spark cluster..."
$SPARK_HOME/sbin/stop-all.sh
echo "Spark cluster stopped."

echo "Stopping Hadoop cluster..."
$HADOOP_HOME/sbin/stop-yarn.sh
$HADOOP_HOME/sbin/stop-dfs.sh
echo "Hadoop cluster stopped."

echo "Everything is stopped."
