#!/bin/bash
sudo service ssh start

/home/hduser/setup.sh

tail -F /dev/null
