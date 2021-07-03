#!/bin/bash
VERSION=$1

cd /home/admin/apps
cp /tmp/ecosystem.config.js .

cd /home/admin/apps/jambonz-api-server && sudo npm install --unsafe-perm
cd /home/admin/apps/jambonz-webapp && sudo npm install --unsafe-perm && npm run build
cd /home/admin/apps/public-apps && sudo npm install --unsafe-perm

sudo -u admin bash -c "pm2 install pm2-logrotate"
sudo -u admin bash -c "pm2 set pm2-logrotate:max_size 1G"
sudo -u admin bash -c "pm2 set pm2-logrotate:retain 5"
sudo -u admin bash -c "pm2 set pm2-logrotate:compress true"

sudo chown -R admin:admin  /home/admin/apps
