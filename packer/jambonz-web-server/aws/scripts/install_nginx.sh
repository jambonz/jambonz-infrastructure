#!/bin/bash

echo "installing nginx"

sudo apt-get install -y nginx

echo "installing apache utils for htpasswd"
sudo apt-get install -y apache2-utils

sudo systemctl enable nginx
sudo systemctl restart nginx

# NB: customization of sites-availble handled in terraform / cloudformation userdatra scripts
