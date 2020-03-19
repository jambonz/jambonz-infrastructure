#!/bin/bash
DATADOG_API_KEY=$1
DATADOG_ENDPOINT=$2
DATADOG_ENV_NAME=$3

# install datadog
DD_INSTALL_ONLY=true DD_API_KEY=${DATADOG_API_KEY} bash -c "$(curl -L https://raw.githubusercontent.com/DataDog/datadog-agent/master/cmd/agent/install_script.sh)"
sudo rm /etc/datadog-agent/conf.d/*

sudo sed -i -e 's@^# dd_url:.*@'"dd_url: $DATADOG_ENDPOINT"'@g' /etc/datadog-agent/datadog.yaml
sudo sed -i -e 's@^# log_level:.*@log_level: warning@g' /etc/datadog-agent/datadog.yaml

sudo tee -a /etc/datadog-agent/datadog.yaml > /dev/null <<EOT
tags:
  env_name:$DATADOG_ENV_NAME
  role:jambonz-feature-server
EOT

systemctl enable datadog-agent
