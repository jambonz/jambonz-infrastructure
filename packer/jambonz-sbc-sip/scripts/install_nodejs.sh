#!/bin/bash
curl -sL https://deb.nodesource.com/setup_10.x | sudo bash - && sudo apt-get install -y nodejs
sudo npm install -g pino-pretty pm2 pm2-logrotate
sudo pm2 install pm2-logrotate
