#!/bin/bash

if [ "$1" == "yes" ]; then 

#install cloudwatch
sudo wget https://s3.amazonaws.com/amazoncloudwatch-agent/debian/amd64/latest/amazon-cloudwatch-agent.deb -O /home/admin/amazon-cloudwatch-agent.deb
sudo dpkg -i -E /home/admin/amazon-cloudwatch-agent.deb
sudo rm -rf /home/admin/amazon-cloudwatch-agent.deb

# install config file for jambonz
sudo cp -r /tmp/cloudwatch-config.json /opt/aws/amazon-cloudwatch-agent/bin/config.json

fi