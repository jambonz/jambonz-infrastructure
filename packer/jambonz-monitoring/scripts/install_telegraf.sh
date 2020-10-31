#!/bin/bash

if [ "$1" == "yes" ]; then 

INFLUXDB_IP=$2

curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -
echo "deb https://repos.influxdata.com/debian stretch stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
sudo apt-get update 
sudo apt-get install -y telegraf

sudo cp /tmp/telegraf.conf /etc/telegraf/telegraf.conf
sudo sed -i -e "s/influxdb:8086/$INFLUXDB_IP:8086/g"  /etc/telegraf/telegraf.conf

sudo systemctl enable telegraf
sudo systemctl start telegraf

fi