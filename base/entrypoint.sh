#!/bin/bash
sudo service ssh start

echo "Setting up Hadoop..."
/home/hduser/setupHadoop.sh
echo "Hadoop setup complete."

echo "Setting up Spark..."
/home/hduser/setupSpark.sh
echo "Spark setup complete."

echo "Everything is ready. Now you can use the cluster."

tail -F /dev/null
