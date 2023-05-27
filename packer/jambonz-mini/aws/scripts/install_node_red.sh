#!/bin/bash

if [ "$1" == "yes" ]; then 

#install node-red
mkdir -p apps && cd $_
git clone https://github.com/node-red/node-red.git
cd node-red
sudo npm install --unsafe-perm
grunt build

sudo mv /tmp/ecosystem.config.js /home/admin/apps
sudo chown -R admin:admin /home/admin/apps

sudo -u admin bash -c "pm2 start /home/admin/apps/ecosystem.config.js"
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u admin --hp /home/admin
sudo -u admin bash -c "pm2 save"
sudo systemctl enable pm2-admin.service

fi