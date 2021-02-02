#!/bin/bash -v
echo "userdata-start"
sudo apt-get update -y
sudo apt-get install -y nginx > /tmp/nginx.log
sudo service nginx start
echo "userdata-end"
