#!/bin/bash
DISTRO=$1

if [ "$2" == "yes" ]; then 

if [[ "$DISTRO" == rhel* ]] ; then
  cat <<EOF | sudo tee /etc/yum.repos.d/influxdb.repo
[influxdb]
name = InfluxDB Repository
baseurl = https://repos.influxdata.com/rhel/\$releasever/\$basearch/stable
enabled = 1
gpgcheck = 1
gpgkey = https://repos.influxdata.com/influxdata-archive_compat.key
EOF
  sudo dnf install -y influxdb
else
  sudo apt-get install -y apt-transport-https
  curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -
  echo "deb https://repos.influxdata.com/debian buster stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
  sudo apt-get update 
  sudo apt-get install -y influxdb
  sudo chmod a+x /usr/lib/influxdb/scripts/influxd-systemd-start.sh
fi
sudo systemctl enable influxdb
sudo systemctl start influxdb

sudo systemctl status influxdb.service

fi