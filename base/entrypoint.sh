#!/bin/bash
sudo service ssh start

/home/hduser/setup.sh

echo "Everything is ready. Now you can use the cluster."

tail -F /dev/null
