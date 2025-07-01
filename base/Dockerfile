FROM debian:12-slim

# Setup Hadoop
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  openjdk-17-jdk \
  net-tools \
  curl \
  netcat \
  gnupg \
  libsnappy-dev \
  && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

RUN curl -O https://downloads.apache.org/hadoop/common/KEYS

RUN gpg --import KEYS

ENV HADOOP_VERSION 3.4.1
ENV HADOOP_URL https://www.apache.org/dyn/closer.cgi/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz

RUN set -x \
  && curl -fSL "${HADOOP_URL}" -o /tmp/hadoop.tar.gz \
  && curl -fSL "${HADOOP_URL}.asc" -o /tmp/hadoop.tar.gz.asc \
  && gpg --verify /tmp/hadoop.tar.gz.asc \
  && tar -xvf /tmp/hadoop.tar.gz -C /opt/ \
  && rm /tmp/hadoop.tar.gz*

RUN ln -s /opt/hadoop-${HADOOP_VERSION}/etc/hadoop /etc/hadoop

RUN mkdir /opt/hadoop-${HADOOP_VERSION}/logs

RUN mkdir /hadoop-data

ENV HADOOP_HOME=/opt/hadoop-${HADOOP_VERSION}
ENV HADOOP_CONF_DIR=/etc/hadoop
ENV MULTIHOMED_NETWORK=1
ENV USER=root
ENV PATH ${HADOOP_HOME}/bin:$PATH

# TODO: Setup Spark
# NOTE: We gonna colocate Spark and Hadoop in the same machine (container).
#
# Ref: https://stackoverflow.com/questions/53877723/can-apache-spark-worker-nodes-be-different-machines-than-hdfs-data-nodes
# In a bare metal set up and as originally postulated by MR, the Data Locality
# principle applies as you state, and Spark would be installed on all the Data
# Nodes, implying they would be also a Worker Node. So, Spark Worker resides on
# Data Node for rack-awareness and Data Locality for HDFS. That said, there are
# other storage managers such as KUDU now and other NOSQL variants that do not
# use HDFS.
#
# With Cloud approaches for Hadoop you see Storage and compute divorced
# necessarily, e.g. AWS EMR and EC2, et al. That cannot be otherwise in terms of
# elasticity in compute. Not that bad as Spark shuffles to same Workers once
# data gotten for related keys where possible.
#
# So, for Cloud the question is not actually relevant anymore. For bare metal
# Spark can be installed on different machines but would not make sense. I would
# install on all HDFS nodes, 5 not 3 as I understand in such a case.

ADD entrypoint.sh /entrypoint.sh

RUN chmod a+x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
