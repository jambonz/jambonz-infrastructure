#!/bin/sh
PRIVATE_IPV4="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
PUBLIC_IPV4="$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
echo "REACT_APP_API_BASE_URL=http://${PUBLIC_IPV4}/api/v1" > /home/admin/apps/jambonz-webapp/.env
cd /home/admin/apps/jambonz-webapp && sudo npm install --unsafe-perm && npm run build

# update ecosystem.config.js with private ip
sudo sed -i -e "s/\(.*\)PRIVATE_IP\(.*\)/\1${PRIVATE_IPV4}\2/g" /home/admin/apps/ecosystem.config.js
sudo -u admin bash -c "pm2 restart /home/admin/apps/ecosystem.config.js"