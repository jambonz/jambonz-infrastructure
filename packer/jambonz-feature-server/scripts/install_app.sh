#!/bin/bash
cd /home/admin
mkdir apps credentials
cp /tmp/ecosystem.config.js apps
cd apps

git clone https://github.com/jambonz/jambonz-feature-server.git

cd /home/admin/apps/jambonz-feature-server && npm install

pm2 install pm2-logrotate
pm2 set pm2-logrotate:max_size 1G
pm2 set pm2-logrotate:retain 5
pm2 set pm2-logrotate:compress true

# add entries to /etc/crontab to start the app on reboot
echo "@reboot admin /usr/bin/pm2 start /home/admin/apps/ecosystem.config.js" | sudo tee -a /etc/crontab
