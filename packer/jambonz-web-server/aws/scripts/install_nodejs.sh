#!/bin/bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_18.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo apt-get update
sudo apt-get install nodejs -y
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
