#!/bin/bash
VERSION=$1
DB_USER=$2
DB_PASS=$3

cd /home/admin
cp /tmp/ecosystem.config.js apps
cd apps

cd /home/admin/apps/jambonz-feature-server && sudo npm install --unsafe-perm
cd /home/admin/apps/fsw-clear-old-calls && npm install && sudo npm install -g .
cd /home/admin/apps/jambonz-api-server && sudo npm install --unsafe-perm
cd /home/admin/apps/jambonz-webapp && sudo npm install --unsafe-perm && npm run build
cd /home/admin/apps/sbc-options-handler && sudo npm install --unsafe-perm
cd /home/admin/apps/sbc-inbound && sudo npm install --unsafe-perm
cd /home/admin/apps/sbc-outbound && sudo npm install --unsafe-perm
cd /home/admin/apps/sbc-registrar && sudo npm install --unsafe-perm
cd /home/admin/apps/sbc-call-router && sudo npm install --unsafe-perm
cd /home/admin/apps/jambonz-api-server && sudo npm install --unsafe-perm

JAMBONES_MYSQL_HOST=localhost JAMBONES_MYSQL_USER=${DB_USER} JAMBONES_MYSQL_PASSWORD=${DB_PASS} JAMBONES_MYSQL_DATABASE=jambones /home/admin/apps/jambonz-api-server/db/reset_admin_password.js

echo "0 *	* * * root    fsw-clear-old-calls --password JambonzR0ck$ >> /var/log/fsw-clear-old-calls.log 2>&1" | sudo tee -a /etc/crontab
echo "0 1	* * * root    find /tmp -name \"*.mp3\" -mtime +2 -exec rm {} \; > /dev/null 2>&1" | sudo tee -a /etc/crontab

sudo -u admin bash -c "pm2 install pm2-logrotate"
sudo -u admin bash -c "pm2 set pm2-logrotate:max_size 1G"
sudo -u admin bash -c "pm2 set pm2-logrotate:retain 5"
sudo -u admin bash -c "pm2 set pm2-logrotate:compress true"

rm 
sudo chown -R admin:admin  /home/admin/apps

sudo rm /home/admin/apps/jambonz-webapp/.env
#sudo cp /tmp/initialize-webapp-userdata.sh /var/lib/cloud/scripts/per-instance
#sudo chmod +x /var/lib/cloud/scripts/per-instance/initialize-webapp-userdata.sh