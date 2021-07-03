#!/bin/bash

echo "installing nginx"

sudo apt-get install -y nginx

cd /etc/nginx/sites-available
sudo mv /tmp/nginx.default default

sudo systemctl enable nginx
sudo systemctl restart nginx

sudo systemctl status nginx
sudo journalctl -xe
