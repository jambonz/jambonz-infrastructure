#!/bin/bash
VERSION=$1
DISTRO=$2

if [ "$DISTRO" == "rhel-9" ]; then
  HOME=/home/ec2-user
  cd $HOME
  mkdir -p apps
  cp /tmp/ecosystem-rhel.config.js apps/ecosystem.config.js
  cd apps
else
  HOME=$HOME
  cd $HOME
  mkdir -p apps
  cp /tmp/ecosystem.config.js apps
  cd apps
fi

echo "building jambonz-feature-server.."
cd $HOME/apps/jambonz-feature-server && npm ci --unsafe-perm
echo "building fsw-clear-old-calls.."
cd $HOME/apps/fsw-clear-old-calls && npm ci --unsafe-perm && sudo npm install -g .

sudo npm install -g pino-pretty pm2 pm2-logrotate gulp grunt

echo "0 *	* * * root    fsw-clear-old-calls --password JambonzR0ck$ >> /var/log/fsw-clear-old-calls.log 2>&1" | sudo tee -a /etc/crontab
echo "0 1	* * * root    find /tmp -name \"*.mp3\" -mtime +2 -exec rm {} \; > /dev/null 2>&1" | sudo tee -a /etc/crontab
echo "0 2	* * * root    find /usr/local/freeswitch/storage/http_file_cache -mtime +7 -exec rm {} \; > /dev/null 2>&1" | sudo tee -a /etc/crontab

if [ "$DISTRO" == "rhel-9" ]; then
  sudo chown -R 1000:1000 /home/ec2-user/.npm
  sudo -u ec2-user bash -c "pm2 install pm2-logrotate"
  sudo -u ec2-user bash -c "pm2 set pm2-logrotate:max_size 1G"
  sudo -u ec2-user bash -c "pm2 set pm2-logrotate:retain 5"
  sudo -u ec2-user bash -c "pm2 set pm2-logrotate:compress true"
  sudo chown -R ec2-user:ec2-user  $HOME/apps
  sudo systemctl enable --now snapd.socket
  sudo ln -s /var/lib/snapd/snap /snap
else
  sudo -u admin bash -c "pm2 install pm2-logrotate"
  sudo -u admin bash -c "pm2 set pm2-logrotate:max_size 1G"
  sudo -u admin bash -c "pm2 set pm2-logrotate:retain 5"
  sudo -u admin bash -c "pm2 set pm2-logrotate:compress true"
  sudo chown -R admin:admin  $HOME/apps
  sudo snap install core
  sudo snap install --classic certbot
  sudo ln -s /snap/bin/certbot /usr/bin/certbot
fi
