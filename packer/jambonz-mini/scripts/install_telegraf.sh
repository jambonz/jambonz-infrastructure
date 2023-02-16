#!/bin/bash

if [ "$1" == "yes" ]; then 

INFLUXDB_IP=$2

cd /tmp
wget -q https://repos.influxdata.com/influxdata-archive_compat.key
gpg --with-fingerprint --show-keys ./influxdata-archive_compat.key
cat influxdata-archive_compat.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/influxdata-archive_compat.gpg > /dev/null
echo 'deb [signed-by=/etc/apt/trusted.gpg.d/influxdata-archive_compat.gpg] https://repos.influxdata.com/debian stable main' | sudo tee /etc/apt/sources.list.d/influxdata.list

#curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -
#curl -sLhttps://repos.influxdata.com/influxdata-archive_compat.key | sudo apt-key add -
#echo "deb https://repos.influxdata.com/debian stretch stable" | sudo tee /etc/apt/sources.list.d/influxdb.list

sudo apt-get update 
sudo apt-get install -y telegraf

sudo cp /tmp/telegraf.conf /etc/telegraf/telegraf.conf
sudo sed -i -e "s/influxdb:8086/$INFLUXDB_IP:8086/g"  /etc/telegraf/telegraf.conf

sudo systemctl enable telegraf
sudo systemctl start telegraf

fi