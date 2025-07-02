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

  entry="<property><name>$name</name><value>${value}</value></property>"
  escapedEntry=$(echo "$entry" | sed 's/\//\\\//g')
  sed -i "/<\/configuration>/ s/.*/${escapedEntry}\n&/" "$path"
}

# configure: configure hadoop config file from environment variables
# args:
#   $1: path to config file (e.g. /etc/hadoop/core-site.xml)
#   $2: module name (e.g. core)
#   $3: environment prefix (e.g. CORE_CONF)
function configure() {
    local path=$1
    local module=$2
    local envPrefix=$3

    local name
    local var
    local value
    
    echo "Configuring $module"
    for c in $(printenv | perl -sne 'print "$1 " if m/^${envPrefix}_(.+?)=.*/' -- -envPrefix="$envPrefix"); do 
        name=$(echo "${c}" | perl -pe 's/___/-/g; s/__/@/g; s/_/./g; s/@/_/g;')
        var="${envPrefix}_${c}"
        value=${!var}
        echo " - Setting $name=$value"
        addProperty "$path" "$name" "$value"
    done
}

configure /opt/hadoop/etc/hadoop/core-site.xml core CORE_CONF
configure /opt/hadoop/etc/hadoop/hdfs-site.xml hdfs HDFS_CONF
configure /opt/hadoop/etc/hadoop/yarn-site.xml yarn YARN_CONF
configure /opt/hadoop/etc/hadoop/httpfs-site.xml httpfs HTTPFS_CONF
configure /opt/hadoop/etc/hadoop/kms-site.xml kms KMS_CONF
configure /opt/hadoop/etc/hadoop/mapred-site.xml mapred MAPRED_CONF

echo "export HADOOP_PID_DIR=/data/hadoop/pid" >> /opt/hadoop/etc/hadoop/hadoop-env.sh

echo "master" > /opt/hadoop/etc/hadoop/workers
echo "worker1" >> /opt/hadoop/etc/hadoop/workers
echo "worker2" >> /opt/hadoop/etc/hadoop/workers

