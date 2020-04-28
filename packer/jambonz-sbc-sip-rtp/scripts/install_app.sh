#!/bin/bash
cd /home/admin
mkdir apps
cp /tmp/ecosystem.config.js apps
cd apps

git clone https://github.com/jambonz/sbc-outbound.git
git clone https://github.com/jambonz/sbc-inbound.git
git clone https://github.com/jambonz/sbc-registrar.git
git clone https://github.com/jambonz/sbc-api-server.git
git clone https://github.com/jambonz/sbc-call-router.git
git clone https://github.com/jambonz/jambonz-api-server.git
git clone https://github.com/jambonz/jambonz-webapp.git

cd /home/admin/apps/sbc-inbound && npm install
cd /home/admin/apps/sbc-outbound && npm install
cd /home/admin/apps/sbc-registrar && npm install
cd /home/admin/apps/sbc-call-router && npm install
cd /home/admin/apps/jambonz-api-server && npm install
cd /home/admin/apps/jambonz-webapp && npm install && npm run build

pm2 install pm2-logrotate
pm2 set pm2-logrotate:max_size 1G
pm2 set pm2-logrotate:retain 5
pm2 set pm2-logrotate:compress true

# add entries to /etc/crontab to start the app on reboot
echo "@reboot admin /usr/bin/pm2 start /home/admin/apps/ecosystem.config.js" | sudo tee -a /etc/crontab
