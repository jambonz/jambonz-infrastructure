#!/bin/bash

echo "installing nginx"

sudo apt-get install -y nginx

sudo systemctl enable nginx
sudo systemctl restart nginx

# NB: customization of sites-availble handled in terraform / cloudformation userdatra scripts
