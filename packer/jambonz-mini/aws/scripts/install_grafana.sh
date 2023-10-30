#!/bin/bash
DISTRO=$1

if [ "$2" = "yes" ]; then 

if [[ "$DISTRO" == rhel* ]] ; then
  sudo tee /etc/yum.repos.d/grafana.repo <<EOF
[grafana]
name=grafana
baseurl=https://packages.grafana.com/oss/rpm
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://packages.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
EOF
  sudo dnf install -y grafana
else
  curl -sL https://packages.grafana.com/gpg.key | sudo apt-key add -
  echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
  sudo apt-get update 
  sudo apt-get install -y grafana
fi

# move to port 3010
sudo sed -i -e "s/;http_port = 3000/http_port = 3010/g" /etc/grafana/grafana.ini

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