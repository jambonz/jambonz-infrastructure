#!/bin/bash
VERSION=$1

cd /home/admin
mkdir apps
cp /tmp/ecosystem.config.js apps
cd apps

git clone https://github.com/jambonz/sbc-outbound.git -b ${VERSION}
git clone https://github.com/jambonz/sbc-inbound.git -b ${VERSION}
git clone https://github.com/jambonz/sbc-registrar.git -b ${VERSION}
git clone https://github.com/jambonz/sbc-call-router.git -b ${VERSION}
git clone https://github.com/jambonz/jambonz-api-server.git -b ${VERSION}
git clone https://github.com/jambonz/jambonz-webapp.git -b ${VERSION}

cd /home/admin/apps/sbc-inbound && npm install
cd /home/admin/apps/sbc-outbound && npm install
cd /home/admin/apps/sbc-registrar && npm install
cd /home/admin/apps/sbc-call-router && npm install
cd /home/admin/apps/jambonz-api-server && npm install
cd /home/admin/apps/jambonz-webapp && npm install && npm run build

sudo -u admin bash -c "pm2 install pm2-logrotate"
sudo -u admin bash -c "pm2 set pm2-logrotate:max_size 1G"
sudo -u admin bash -c "pm2 set pm2-logrotate:retain 5"
sudo -u admin bash -c "pm2 set pm2-logrotate:compress true"
