#!/bin/bash

configDir=/opt/hadoop/etc/hadoop

addPropertyPy=/home/hduser/addProperty.py

python3 $addPropertyPy $configDir/core-site.xml fs.defaultFS hdfs://master:9000
python3 $addPropertyPy $configDir/core-site.xml hadoop.tmp.dir /data/hadoop/tmp

python3 $addPropertyPy $configDir/hdfs-site.xml dfs.replication 3
python3 $addPropertyPy $configDir/hdfs-site.xml dfs.datanode.data.dir /data/hadoop/data
python3 $addPropertyPy $configDir/hdfs-site.xml dfs.namenode.name.dir /data/hadoop/name

python3 $addPropertyPy $configDir/yarn-site.xml yarn.resourcemanager.hostname master
python3 $addPropertyPy $configDir/yarn-site.xml yarn.nodemanager.aux-services mapreduce_shuffle
python3 $addPropertyPy $configDir/yarn-site.xml yarn.nodemanager.env-whitelist JAVA_HOME,HADOOP_COMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,CLASSPATH_PREPEND_DISTCACHE,HADOOP_YARN_HOME,HADOOP_MAPRED_HOME

python3 $addPropertyPy $configDir/mapred-site.xml mapreduce.framework.name yarn
python3 $addPropertyPy $configDir/mapred-site.xml mapreduce.application.classpath /opt/hadoop/share/hadoop/mapreduce/*:/opt/hadoop/share/hadoop/mapreduce/lib/*

JAVA11_HOME=/usr/lib/jvm/java-11-openjdk-amd64

echo "export JAVA_HOME=$JAVA11_HOME" >> /opt/hadoop/etc/hadoop/hadoop-env.sh
echo "export HADOOP_PID_DIR=/data/hadoop/pid" >> /opt/hadoop/etc/hadoop/hadoop-env.sh
echo "export HADOOP_LOG_DIR=/data/hadoop/logs" >> /opt/hadoop/etc/hadoop/hadoop-env.sh

echo "master" > /opt/hadoop/etc/hadoop/workers
echo "worker1" >> /opt/hadoop/etc/hadoop/workers
echo "worker2" >> /opt/hadoop/etc/hadoop/workers

if [ "$(hostname)" == "master" ]; then
    python3 $addPropertyPy /opt/hadoop/etc/hadoop/yarn-site.xml yarn.nodemanager.hostname master
fi

if [ "$(hostname)" == "worker1" ]; then
    python3 $addPropertyPy /opt/hadoop/etc/hadoop/yarn-site.xml yarn.nodemanager.hostname worker1
fi

if [ "$(hostname)" == "worker2" ]; then
    python3 $addPropertyPy /opt/hadoop/etc/hadoop/yarn-site.xml yarn.nodemanager.hostname worker2
fi

if [ "$(hostname)" == "master" ]; then
    # start hadoop namenode
    hadoop namenode -format
    /opt/hadoop/sbin/start-dfs.sh
    /opt/hadoop/sbin/start-yarn.sh
fi
