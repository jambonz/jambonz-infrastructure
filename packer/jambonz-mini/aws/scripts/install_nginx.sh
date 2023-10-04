#!/bin/bash
DISTRO=$1

echo "installing nginx"

if [[ "$DISTRO" == rhel* ]]; then
  sudo dnf install -y nginx httpd-tools
  cd /etc/nginx/conf.d
  sudo mv /tmp/nginx.default default
else
  sudo apt-get install -y nginx apache2-utils
  cd /etc/nginx/sites-available
  sudo mv /tmp/nginx.default default
fi


sudo systemctl enable nginx
sudo systemctl restart nginx

sudo systemctl status nginx
