#!/bin/bash
VERSION=$1

cd /home/admin/apps
cp /tmp/ecosystem.config.js .

echo "building jambonz-api-server.."
cd /home/admin/apps/jambonz-api-server && npm ci
echo "building jambonz-webapp.."
cd /home/admin/apps/jambonz-webapp && npm ci && npm run build
echo "building public-apps.."
mkdir -p /home/admin/apps/public-apps
cd /home/admin/apps/public-apps && npm install

sudo npm install -g pino-pretty pm2 pm2-logrotate gulp grunt

sudo -u admin bash -c "pm2 install pm2-logrotate"
sudo -u admin bash -c "pm2 set pm2-logrotate:max_size 1G"
sudo -u admin bash -c "pm2 set pm2-logrotate:retain 5"
sudo -u admin bash -c "pm2 set pm2-logrotate:compress true"

sudo chown -R admin:admin  /home/admin/apps

sudo cp /tmp/auto-assign-elastic-ip.sh /usr/local/bin
sudo chmod +x /usr/local/bin/auto-assign-elastic-ip.sh
