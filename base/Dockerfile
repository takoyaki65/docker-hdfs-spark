FROM debian:12-slim AS download-hadoop-spark

ENV HADOOP_VERSION=3.4.1
ENV HADOOP_MAJOR_VERSION=3
ENV HADOOP_URL=https://dlcdn.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  gnupg \
  && rm -rf /var/lib/apt/lists/*

RUN curl -O https://downloads.apache.org/hadoop/common/KEYS

RUN gpg --import KEYS

RUN set -x \
  && curl -fSL "${HADOOP_URL}" -o /tmp/hadoop.tar.gz \
  && curl -fSL "${HADOOP_URL}.asc" -o /tmp/hadoop.tar.gz.asc \
  && gpg --verify /tmp/hadoop.tar.gz.asc \
  && tar -xvf /tmp/hadoop.tar.gz -C /opt/ \
  && rm /tmp/hadoop.tar.gz*

ENV SPARK_VERSION=4.0.0
ENV SPARK_URL="https://dlcdn.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_MAJOR_VERSION}.tgz"

RUN curl -O https://downloads.apache.org/spark/KEYS

RUN gpg --import KEYS

RUN set -x \
  && curl -fSL "${SPARK_URL}" -o /tmp/spark.tar.gz \
  && curl -fSL "${SPARK_URL}.asc" -o /tmp/spark.tar.gz.asc \
  && gpg --verify /tmp/spark.tar.gz.asc \
  && tar -xvf /tmp/spark.tar.gz -C /opt/ \
  && rm /tmp/spark.tar.gz*

FROM ubuntu:24.10

ENV SPARK_VERSION=4.0.0
ENV HADOOP_VERSION=3.4.1
ENV HADOOP_MAJOR_VERSION=3

# Setup Hadoop
# ref: https://github.com/big-data-europe/docker-hadoop/blob/master/base/Dockerfile
RUN apt-get update && apt-get install -y --no-install-recommends \
  openjdk-11-jdk \
  openjdk-17-jdk \
  net-tools \
  curl \
  netcat-traditional \
  gnupg \
  libsnappy-dev \
  openssh-server \
  sudo \
  htop \
  pdsh \
  python3 \
  && rm -rf /var/lib/apt/lists/*

# set openjdk-17 as default
RUN update-alternatives --set java /usr/lib/jvm/java-17-openjdk-amd64/bin/java
RUN update-alternatives --set javac /usr/lib/jvm/java-17-openjdk-amd64/bin/javac

# Setup Hadoop user, who can access to each machine in the cluster via ssh.
# ref: https://medium.com/codex/running-a-multi-node-hadoop-cluster-257068e5f276

RUN groupadd hadoop \
  && useradd -m hduser \
  && usermod -aG hadoop hduser \
  && usermod -aG sudo hduser \
  && passwd -d hduser

RUN mkdir -p /data/hadoop \
  && mkdir -p /data/hadoop/data \
  && mkdir -p /data/hadoop/name \
  && mkdir -p /data/hadoop/pid \
  && mkdir -p /data/hadoop/tmp \
  && mkdir -p /data/spark/local \
  && mkdir -p /data/spark/logs \
  && mkdir -p /data/spark/pid \
  && mkdir -p /data/spark/work \
  && chown -R hduser:hadoop /data

USER hduser

COPY --chown=hduser:hadoop --from=download-hadoop-spark /opt/hadoop-${HADOOP_VERSION} /opt/hadoop-${HADOOP_VERSION}
RUN sudo ln -s /opt/hadoop-${HADOOP_VERSION} /opt/hadoop

RUN mkdir /opt/hadoop-${HADOOP_VERSION}/logs

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

# ref: https://github.com/big-data-europe/docker-spark/blob/master/base/Dockerfile
ENV SPARK_VERSION=4.0.0

COPY --chown=hduser:hadoop --from=download-hadoop-spark /opt/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_MAJOR_VERSION} /opt/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_MAJOR_VERSION}
RUN sudo ln -s /opt/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_MAJOR_VERSION} /opt/spark

RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa \
  && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys \
  && chmod 0600 ~/.ssh/authorized_keys

# Setting default shell to bash when accessing another container via ssh.
RUN sudo chsh -s /bin/bash hduser

ADD --chown=hduser:hadoop setupHadoop.sh /home/hduser/setupHadoop.sh
ADD --chown=hduser:hadoop setupSpark.sh /home/hduser/setupSpark.sh
ADD --chown=hduser:hadoop entrypoint.sh /home/hduser/entrypoint.sh
ADD --chown=hduser:hadoop stopAll.sh /home/hduser/stopAll.sh

RUN chmod a+x /home/hduser/setupHadoop.sh
RUN chmod a+x /home/hduser/setupSpark.sh
RUN chmod a+x /home/hduser/entrypoint.sh
RUN chmod a+x /home/hduser/stopAll.sh

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop
ENV PATH=${HADOOP_HOME}/bin:$PATH

ENV SPARK_HOME=/opt/spark
ENV PATH=${SPARK_HOME}/bin:$PATH

RUN printf "export JAVA_HOME=${JAVA_HOME}\n" >> /home/hduser/.bashrc \
  && printf "export HADOOP_HOME=${HADOOP_HOME}\n" >> /home/hduser/.bashrc \
  && printf "export HADOOP_CONF_DIR=${HADOOP_CONF_DIR}\n" >> /home/hduser/.bashrc \
  && printf "export PATH=${HADOOP_HOME}/bin:\$PATH\n" >> /home/hduser/.bashrc \
  && printf "export SPARK_HOME=${SPARK_HOME}\n" >> /home/hduser/.bashrc \
  && printf "export PATH=${SPARK_HOME}/bin:\$PATH\n" >> /home/hduser/.bashrc \
  && printf "export HADOOP_MAPRED_HOME=${HADOOP_HOME}\n" >> /home/hduser/.bashrc \
  && printf "export HADOOP_HDFS_HOME=${HADOOP_HOME}\n" >> /home/hduser/.bashrc \
  && printf "export HADOOP_YARN_HOME=${HADOOP_HOME}\n" >> /home/hduser/.bashrc \
  && printf "export HDFS_NAMENODE_USER=hduser\n" >> /home/hduser/.bashrc \
  && printf "export HDFS_DATANODE_USER=hduser\n" >> /home/hduser/.bashrc \
  && printf "export HDFS_SECONDARYNAMENODE_USER=hduser\n" >> /home/hduser/.bashrc \
  && printf "export YARN_RESOURCEMANAGER_USER=hduser\n" >> /home/hduser/.bashrc \
  && printf "export YARN_NODEMANAGER_USER=hduser\n" >> /home/hduser/.bashrc 
