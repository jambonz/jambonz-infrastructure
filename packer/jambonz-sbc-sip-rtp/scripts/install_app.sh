#!/bin/bash
VERSION=$1

cd /home/admin
cp /tmp/ecosystem.config.js apps
cd apps

cd /home/admin/apps/sbc-options-handler && sudo npm install --unsafe-perm
cd /home/admin/apps/sbc-inbound && sudo npm install --unsafe-perm
cd /home/admin/apps/sbc-outbound && sudo npm install --unsafe-perm
cd /home/admin/apps/sbc-registrar && sudo npm install --unsafe-perm
cd /home/admin/apps/sbc-call-router && sudo npm install --unsafe-perm
cd /home/admin/apps/jambonz-api-server && sudo npm install --unsafe-perm
cd /ho
sudo npm install -g pino-pretty pm2 pm2-logrotate gulp grunt

sudo -u admin bash -c "pm2 install pm2-logrotate"
sudo -u admin bash -c "pm2 set pm2-logrotate:max_size 1G"
sudo -u admin bash -c "pm2 set pm2-logrotate:retain 5"
sudo -u admin bash -c "pm2 set pm2-logrotate:compress true"

sudo chown -R admin:admin  /home/admin/apps
