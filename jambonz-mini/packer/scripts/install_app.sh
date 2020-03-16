#!/bin/bash
cd /home/admin
mkdir apps credentials
cp /tmp/ecosystem.config.js apps
cd apps

git clone https://github.com/jambonz/sbc-outbound.git
git clone https://github.com/jambonz/sbc-inbound.git
git clone https://github.com/jambonz/sbc-registrar.git
git clone https://github.com/jambonz/sbc-api-server.git
git clone https://github.com/jambonz/sbc-call-router.git
git clone https://github.com/jambonz/jambonz-api-server.git
git clone https://github.com/jambonz/jambonz-feature-server.git

cd /home/admin/apps/sbc-inbound && npm install
cd /home/admin/apps/sbc-outbound && npm install
cd /home/admin/apps/sbc-registrar && npm install
cd /home/admin/apps/sbc-call-router && npm install
cd /home/admin/apps/jambonz-api-server && npm install
cd /home/admin/apps/jambonz-feature-server && npm install

# add entries to /etc/crontab to start everything on reboot
echo "@reboot admin /usr/bin/pm2 start /home/admin/apps/ecosystem.config.js" | sudo tee -a /etc/crontab
echo "@reboot admin sudo env PATH=$PATH:/usr/bin pm2 logrotate -u admin" | sudo tee -a /etc/crontab
