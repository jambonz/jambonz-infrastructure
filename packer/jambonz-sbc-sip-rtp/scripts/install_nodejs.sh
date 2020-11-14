#!/bin/bash
curl -sL https://deb.nodesource.com/setup_14.x | sudo bash - && sudo apt-get install -y nodejs
sudo npm install -g pino-pretty pm2 pm2-logrotate
