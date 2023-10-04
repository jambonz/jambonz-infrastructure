#!/bin/bash
DISTRO=$1
VERSION=$2
DB_USER=$3
DB_PASS=$4
RHEL_RELEASE=""

if [[ "$DISTRO" == rhel* ]]; then
    RHEL_RELEASE="${DISTRO:5}"
    HOME=/home/ec2-user
    sed -i "s|/home/admin|${HOME}|g" /tmp/ecosystem.config.js
else
    HOME=/home/admin
fi

ALIAS_LINE="alias gl='git log --oneline --decorate'"
echo "$ALIAS_LINE" >> ~/.bash_aliases

cd $HOME
cp /tmp/ecosystem.config.js apps

echo "building jambonz-feature-server.."
cd $HOME/apps/jambonz-feature-server && npm ci --unsafe-perm
echo "building fsw-clear-old-calls.."
cd $HOME/apps/fsw-clear-old-calls && npm ci --unsafe-perm && sudo npm install -g .
echo "building jambonz-api-server.."
cd $HOME/apps/jambonz-api-server && npm ci --unsafe-perm
echo "building jambonz-webapp.."
cd $HOME/apps/jambonz-webapp && npm ci --unsafe-perm && npm run build
echo "building sbc-sip-sidecar.."
cd $HOME/apps/sbc-sip-sidecar && npm ci --unsafe-perm
echo "building sbc-inbound.."
cd $HOME/apps/sbc-inbound  && npm ci --unsafe-perm 
echo "building sbc-outbound.."
cd $HOME/apps/sbc-outbound && npm ci --unsafe-perm 
echo "building sbc-call-router.."
cd $HOME/apps/sbc-call-router  && npm ci --unsafe-perm 
echo "building jambonz-smpp-esme.."
cd $HOME/apps/jambonz-smpp-esme && npm ci --unsafe-perm
echo "building sbc-rtpengine-sidecar.."
cd $HOME/apps/sbc-rtpengine-sidecar && npm ci --unsafe-perm 

echo "0 *	* * * root    fsw-clear-old-calls --password JambonzR0ck$ >> /var/log/fsw-clear-old-calls.log 2>&1" | sudo tee -a /etc/crontab
echo "0 1	* * * root    find /tmp -name \"*.mp3\" -mtime +2 -exec rm {} \; > /dev/null 2>&1" | sudo tee -a /etc/crontab

sudo npm install -g pino-pretty pm2 pm2-logrotate gulp grunt

if [[ "$DISTRO" == rhel* ]]; then
  sudo pm2 install pm2-logrotate
  sudo pm2 set pm2-logrotate:max_size 1G
  sudo pm2 set pm2-logrotate:retain 5
  sudo pm2 set pm2-logrotate:compress true
  sudo chown -R ec2-user:ec2-user  $HOME/apps

  sudo ln -s /var/lib/snapd/snap /snap
  sudo systemctl enable snapd
  sudo systemctl start snapd
  sudo snap install --classic certbot
  sudo ln -s /snap/bin/certbot /usr/bin/certbot
else
  sudo -u admin bash -c "pm2 install pm2-logrotate"
  sudo -u admin bash -c "pm2 set pm2-logrotate:max_size 1G"
  sudo -u admin bash -c "pm2 set pm2-logrotate:retain 5"
  sudo -u admin bash -c "pm2 set pm2-logrotate:compress true"
  sudo chown -R admin:admin  $HOME/apps

  sudo snap install core
  sudo snap install --classic certbot
  sudo rm /usr/bin/certbot
  sudo ln -s /snap/bin/certbot /usr/bin/certbot
fi
sudo rm $HOME/apps/jambonz-webapp/.env

