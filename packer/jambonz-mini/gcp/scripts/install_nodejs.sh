#!/bin/bash
curl -sL https://deb.nodesource.com/setup_18.x | sudo bash - && sudo apt-get install -y nodejs
sudo npm install -g npm@latest
node -v
npm -v
sudo ls -lrt /root/.npm/
sudo ls -lrt /root/.npm/_logs
sudo ls -lrt /root/.npm/_cacache
sudo chmod -R a+wx /root
sudo chown -R 1000:1000 /root/.npm
ls -lrt /root/.npm/
ls -lrt /root/.npm/_logs
ls -lrt /root/.npm/_cacache
