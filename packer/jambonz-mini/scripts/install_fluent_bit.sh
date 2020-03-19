#!/bin/bash
FLUENTD_ENDPOINT=$1

wget -qO - https://packages.fluentbit.io/fluentbit.key | sudo apt-key add -
echo "deb https://packages.fluentbit.io/debian/stretch stretch main" | sudo tee -a /etc/apt/sources.list
sudo apt-get update
sudo apt-get install td-agent-bit
sudo mv /tmp/td-agent-bit.conf /etc/td-agent-bit

sudo sed -i -e 's!\(^.*Host\).*!'"\1         $FLUENTD_ENDPOINT"'!g' /etc/td-agent-bit/td-agent-bit.conf
systemctl daemon-reload
systemctl enable td-agent-bit
