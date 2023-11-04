#!/bin/bash
DISTRO=$1
VERSION=$2
RHEL_RELEASE=""

if [ "$DISTRO" == rhel* ]; then
  RHEL_RELEASE="${DISTRO:5}"
  HOME=/home/ec2-user
  sed -i "s|/home/admin|${HOME}|g" /tmp/ecosystem.config.js
else
  HOME=$HOME
  cd $HOME
fi

ALIAS_LINE="alias gl='git log --oneline --decorate'"
echo "$ALIAS_LINE" >> ~/.bash_aliases

cd $HOME
mkdir -p apps
cp /tmp/ecosystem.config.js apps

echo "building jambonz-feature-server.."
cd $HOME/apps/jambonz-feature-server && npm ci --unsafe-perm
echo "building fsw-clear-old-calls.."
cd $HOME/apps/fsw-clear-old-calls && npm ci --unsafe-perm && sudo npm install -g .

echo "0 *	* * * root    fsw-clear-old-calls --password JambonzR0ck$ >> /var/log/fsw-clear-old-calls.log 2>&1" | sudo tee -a /etc/crontab
echo "0 1	* * * root    find /tmp -name \"*.mp3\" -mtime +2 -exec rm {} \; > /dev/null 2>&1" | sudo tee -a /etc/crontab
echo "0 2	* * * root    find /usr/local/freeswitch/storage/http_file_cache -mtime +7 -exec rm {} \; > /dev/null 2>&1" | sudo tee -a /etc/crontab

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
fi
