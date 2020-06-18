#!/bin/bash
VERSION=$1

cd /home/admin
mkdir apps credentials
cp /tmp/ecosystem.config.js apps
cd apps

git clone https://github.com/jambonz/jambonz-feature-server.git -b ${VERSION}
git clone https://github.com/jambonz/fsw-clear-old-calls.git

cd /home/admin/apps/jambonz-feature-server && npm install
cd /home/admin/apps/fsw-clear-old-calls && npm install && sudo npm install -g .

echo "0 *	* * *	root    fsw-clear-old-calls --password JambonzR0ck$ >> /var/log/fsw-clear-old-calls.log 2>&1" | sudo tee -a /etc/crontab

sudo -u admin bash -c "pm2 install pm2-logrotate"
sudo -u admin bash -c "pm2 set pm2-logrotate:max_size 1G"
sudo -u admin bash -c "pm2 set pm2-logrotate:retain 5"
sudo -u admin bash -c "pm2 set pm2-logrotate:compress true"
