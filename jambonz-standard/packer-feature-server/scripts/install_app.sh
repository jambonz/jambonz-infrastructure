#!/bin/bash
cd /home/admin
mkdir apps credentials
cp /tmp/ecosystem.config.js apps
cd apps

git clone https://github.com/jambonz/jambonz-feature-server.git

cd /home/admin/apps/jambonz-feature-server && npm install

# add entries to /etc/crontab to start everything on reboot
echo "@reboot admin /usr/bin/pm2 start /home/admin/apps/ecosystem.config.js" | sudo tee -a /etc/crontab
echo "@reboot admin sudo env PATH=$PATH:/usr/bin pm2 logrotate -u admin" | sudo tee -a /etc/crontab
