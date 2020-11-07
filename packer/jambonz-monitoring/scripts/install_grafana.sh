#!/bin/bash
if [ "$1" = "yes" ]; then 

curl -sL https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
sudo apt-get update 
sudo apt-get install -y grafana
sudo mkdir /var/lib/grafana/dashboards
sudo mv /tmp/grafana-dashboard-default.yaml /etc/grafana/provisioning/dashboards/default.yaml
sudo mv /tmp/grafana-datasource.yml /etc/grafana/provisioning/datasources/datasource.yml

sudo mv /tmp/grafana-dashboard-heplify.json /var/lib/grafana/dashboards
sudo mv /tmp/grafana-dashboard-jambonz.json /var/lib/grafana/dashboards
sudo mv /tmp/grafana-dashboard-servers.json /var/lib/grafana/dashboards

sudo chown -R grafana:grafana /var/lib/grafana/dashboards
sudo chown -R grafana:grafana /etc/grafana/provisioning/dashboards

sudo systemctl enable grafana-server
sudo systemctl start grafana-server

fi