#!/bin/bash
sudo apt-get install -y apt-transport-https
curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -
echo "deb https://repos.influxdata.com/debian stretch stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
sudo apt-get update 
sudo apt-get install -y influxdb
sudo systemctl enable influxdb
sudo systemctl start influxdb
