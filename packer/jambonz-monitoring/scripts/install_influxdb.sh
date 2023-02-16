#!/bin/bash

if [ "$1" == "yes" ]; then 

sudo apt-get install -y apt-transport-https

cd /tmp
wget -q https://repos.influxdata.com/influxdata-archive_compat.key
gpg --with-fingerprint --show-keys ./influxdata-archive_compat.key
cat influxdata-archive_compat.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/influxdata-archive_compat.gpg > /dev/null
echo 'deb [signed-by=/etc/apt/trusted.gpg.d/influxdata-archive_compat.gpg] https://repos.influxdata.com/debian stable main' | sudo tee /etc/apt/sources.list.d/influxdata.list

sudo apt-get update 
sudo apt-get install -y influxdb
sudo systemctl enable influxdb
sudo systemctl start influxdb

fi