#!/bin/bash

if [ "$1" == "yes" ]; then 

sudo apt-get install -y apt-transport-https
curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -
echo "deb https://repos.influxdata.com/debian buster stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
sudo apt-get update 
sudo apt-get install -y influxdb
sudo chmod a+x /usr/lib/influxdb/scripts/influxd-systemd-start.sh
sudo systemctl enable influxdb
sudo systemctl start influxdb

sudo systemctl status influxdb.service

fi