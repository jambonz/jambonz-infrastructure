#!/bin/bash
DISTRO=$1

if [ "$2" == "yes" ]; then 

  #install cloudwatch
if [[ "$DISTRO" == rhel* ]]; then
    sudo wget https://s3.amazonaws.com/amazoncloudwatch-agent/redhat/amd64/latest/amazon-cloudwatch-agent.rpm -O /tmp/amazon-cloudwatch-agent.rpm
    sudo dnf install -y /tmp/amazon-cloudwatch-agent.rpm
    sudo rm -rf /tmp/amazon-cloudwatch-agent.rpm
  else
    sudo wget https://s3.amazonaws.com/amazoncloudwatch-agent/debian/amd64/latest/amazon-cloudwatch-agent.deb -O /home/admin/amazon-cloudwatch-agent.deb
    sudo dpkg -i -E /home/admin/amazon-cloudwatch-agent.deb
    sudo rm -rf /home/admin/amazon-cloudwatch-agent.deb
  fi

  # install config file for jambonz
  sudo cp -r /tmp/cloudwatch-config.json /opt/aws/amazon-cloudwatch-agent/bin/config.json

fi