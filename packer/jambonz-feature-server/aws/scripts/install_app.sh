#!/bin/bash
VERSION=$1

cd /home/admin
cp /tmp/ecosystem.config.js apps
cd apps

echo "building jambonz-feature-server.."
cd /home/admin/apps/jambonz-feature-server && npm ci --unsafe-perm
echo "building fsw-clear-old-calls.."
cd /home/admin/apps/fsw-clear-old-calls && npm ci --unsafe-perm && sudo npm install -g .

sudo npm install -g pino-pretty pm2 pm2-logrotate gulp grunt

echo "0 *	* * * root    fsw-clear-old-calls --password JambonzR0ck$ >> /var/log/fsw-clear-old-calls.log 2>&1" | sudo tee -a /etc/crontab
echo "0 1	* * * root    find /tmp -name \"*.mp3\" -mtime +2 -exec rm {} \; > /dev/null 2>&1" | sudo tee -a /etc/crontab
echo "0 2	* * * root    find /usr/local/freeswitch/storage/http_file_cache -mtime +7 -exec rm {} \; > /dev/null 2>&1" | sudo tee -a /etc/crontab

sudo -u admin bash -c "pm2 install pm2-logrotate"
sudo -u admin bash -c "pm2 set pm2-logrotate:max_size 1G"
sudo -u admin bash -c "pm2 set pm2-logrotate:retain 5"
sudo -u admin bash -c "pm2 set pm2-logrotate:compress true"

sudo chown -R admin:admin  /home/admin/apps
