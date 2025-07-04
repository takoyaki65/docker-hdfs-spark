#!/bin/bash

# addProperty: add property to hadoop config file
# args:
#   $1: path to config file (e.g. /etc/hadoop/core-site.xml)
#   $2: property name (e.g. fs.defaultFS)
#   $3: property value (e.g. hdfs://namenode:9000)
function addProperty() {
  local path=$1
  local name=$2
  local value=$3

  local entry
  local escapedEntry

  echo "Adding property $name=$value to $path"

  entry="<property><name>$name</name><value>${value}</value></property>"
  escapedEntry=$(echo "$entry" | sed 's/\//\\\//g')
  sed -i "/<\/configuration>/ s/.*/${escapedEntry}\n&/" "$path"
}

configDir=/opt/hadoop/etc/hadoop

addProperty $configDir/core-site.xml fs.defaultFS hdfs://master:9000
addProperty $configDir/core-site.xml hadoop.tmp.dir /data/hadoop/tmp

addProperty $configDir/hdfs-site.xml dfs.replication 3
addProperty $configDir/hdfs-site.xml dfs.datanode.data.dir /data/hadoop/data
addProperty $configDir/hdfs-site.xml dfs.namenode.name.dir /data/hadoop/name

addProperty $configDir/yarn-site.xml yarn.resourcemanager.hostname master
addProperty $configDir/yarn-site.xml yarn.nodemanager.aux-services mapreduce_shuffle
addProperty $configDir/yarn-site.xml yarn.web-proxy.address master:9046
addProperty $configDir/yarn-site.xml yarn.nodemanager.env-whitelist JAVA_HOME,HADOOP_COMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,CLASSPATH_PREPEND_DISTCACHE,HADOOP_YARN_HOME,HADOOP_MAPRED_HOME

addProperty $configDir/mapred-site.xml mapreduce.framework.name yarn
addProperty $configDir/mapred-site.xml mapreduce.application.classpath /opt/hadoop/share/hadoop/mapreduce/*:/opt/hadoop/share/hadoop/mapreduce/lib/*

JAVA11_HOME=/usr/lib/jvm/java-11-openjdk-amd64

echo "export JAVA_HOME=$JAVA11_HOME" >> /opt/hadoop/etc/hadoop/hadoop-env.sh
echo "export HADOOP_PID_DIR=/data/hadoop/pid" >> /opt/hadoop/etc/hadoop/hadoop-env.sh

echo "master" > /opt/hadoop/etc/hadoop/workers
echo "worker1" >> /opt/hadoop/etc/hadoop/workers
echo "worker2" >> /opt/hadoop/etc/hadoop/workers

if [ "$(hostname)" == "master" ]; then
    addProperty /opt/hadoop/etc/hadoop/yarn-site.xml yarn.nodemanager.hostname master
fi

if [ "$(hostname)" == "worker1" ]; then
    addProperty /opt/hadoop/etc/hadoop/yarn-site.xml yarn.nodemanager.hostname worker1
fi

if [ "$(hostname)" == "worker2" ]; then
    addProperty /opt/hadoop/etc/hadoop/yarn-site.xml yarn.nodemanager.hostname worker2
fi

if [ "$(hostname)" == "master" ]; then
    # start hadoop namenode
    hadoop namenode -format
    /opt/hadoop/sbin/start-dfs.sh
    /opt/hadoop/sbin/start-yarn.sh
fi
