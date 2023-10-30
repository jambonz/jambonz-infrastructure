#!/bin/bash
DISTRO=$2

if [ "$1" == "yes" ]; then 

INFLUXDB_IP=$2

cd /tmp

if [ "$DISTRO" == "rhel-9" ]; then
  cat <<EOF | sudo tee /etc/yum.repos.d/influxdata.repo
[influxdata]
name = InfluxData Repository
baseurl = https://repos.influxdata.com/rhel/\$releasever/\$basearch/stable
enabled = 1
gpgcheck = 1
gpgkey = https://repos.influxdata.com/influxdata-archive_compat.key
EOF
  echo checking disk space
  df -h
  dnf clean packages
  echo after cleaning packages
  df -h
  sudo dnf install -y telegraf
else
  wget -q https://repos.influxdata.com/influxdata-archive_compat.key
  gpg --with-fingerprint --show-keys ./influxdata-archive_compat.key
  cat influxdata-archive_compat.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/influxdata-archive_compat.gpg > /dev/null
  echo 'deb [signed-by=/etc/apt/trusted.gpg.d/influxdata-archive_compat.gpg] https://repos.influxdata.com/debian stable main' | sudo tee /etc/apt/sources.list.d/influxdata.list

  sudo apt-get update 
  sudo apt-get install -y telegraf
fi

sudo cp /tmp/telegraf.conf /etc/telegraf/telegraf.conf

sudo systemctl enable telegraf
sudo systemctl start telegraf

fi