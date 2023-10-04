#!/bin/bash

echo "installing nginx"

sudo apt-get install -y nginx

echo "installing apache utils for htpasswd"
sudo apt-get install -y apache2-utils

cd /etc/nginx/sites-available
sudo mv /tmp/nginx.default default

sudo systemctl enable nginx
sudo systemctl restart nginx

sudo systemctl status nginx
