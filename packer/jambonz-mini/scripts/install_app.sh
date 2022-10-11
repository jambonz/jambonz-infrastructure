#!/bin/bash
VERSION=$1
DB_USER=$2
DB_PASS=$3

cd /home/admin
cp /tmp/ecosystem.config.js apps

echo "building jambonz-feature-server.."
cd /home/admin/apps/jambonz-feature-server && npm ci --unsafe-perm
echo "building fsw-clear-old-calls.."
cd /home/admin/apps/fsw-clear-old-calls && npm ci --unsafe-perm && sudo npm install -g .
echo "building jambonz-api-server.."
cd /home/admin/apps/jambonz-api-server && npm ci --unsafe-perm
echo "building jambonz-webapp.."
cd /home/admin/apps/jambonz-webapp && npm ci --unsafe-perm && npm run build
echo "building sbc-sip-sidecar.."
cd /home/admin/apps/sbc-sip-sidecar && npm ci --unsafe-perm
echo "building sbc-inbound.."
cd /home/admin/apps/sbc-inbound  && npm ci --unsafe-perm 
echo "building sbc-outbound.."
cd /home/admin/apps/sbc-outbound && npm ci --unsafe-perm 
echo "building sbc-registrar.."
cd /home/admin/apps/sbc-call-router  && npm ci --unsafe-perm 
echo "building jambonz-smpp-esme.."
cd /home/admin/apps/jambonz-smpp-esme && npm ci --unsafe-perm
echo "building sbc-rtpengine-sidecar.."
cd /home/admin/apps/sbc-rtpengine-sidecar && npm ci --unsafe-perm 

sudo npm install -g pino-pretty pm2 pm2-logrotate gulp grunt
sudo pm2 install pm2-logrotate

echo "0 *	* * * root    fsw-clear-old-calls --password JambonzR0ck$ >> /var/log/fsw-clear-old-calls.log 2>&1" | sudo tee -a /etc/crontab
echo "0 1	* * * root    find /tmp -name \"*.mp3\" -mtime +2 -exec rm {} \; > /dev/null 2>&1" | sudo tee -a /etc/crontab

sudo -u admin bash -c "pm2 install pm2-logrotate"
sudo -u admin bash -c "pm2 set pm2-logrotate:max_size 1G"
sudo -u admin bash -c "pm2 set pm2-logrotate:retain 5"
sudo -u admin bash -c "pm2 set pm2-logrotate:compress true"

sudo chown -R admin:admin  /home/admin/apps

sudo rm /home/admin/apps/jambonz-webapp/.env
