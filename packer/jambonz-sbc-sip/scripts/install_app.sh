#!/bin/bash
VERSION=$1

cd /home/admin
mkdir -p apps
cp /tmp/ecosystem.config.js apps
cd apps

cd /home/admin/apps/sbc-inbound && npm ci --unsafe-perm
cd /home/admin/apps/sbc-outbound && npm ci --unsafe-perm
cd /home/admin/apps/sbc-call-router && npm ci --unsafe-perm
cd /home/admin/apps/sbc-sip-sidecar && npm ci --unsafe-perm
cd /home/admin/apps/jambonz-smpp-esme && npm ci --unsafe-perm

sudo npm install -g pino-pretty pm2 pm2-logrotate gulp grunt

sudo -u admin bash -c "pm2 install pm2-logrotate"
sudo -u admin bash -c "pm2 set pm2-logrotate:max_size 1G"
sudo -u admin bash -c "pm2 set pm2-logrotate:retain 5"
sudo -u admin bash -c "pm2 set pm2-logrotate:compress true"

sudo chown -R admin:admin  /home/admin/apps
