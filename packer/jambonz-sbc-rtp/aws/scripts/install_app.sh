cd $HOME
mkdir -p apps
cp /tmp/ecosystem.config.js apps

cd $HOME/apps/sbc-rtpengine-sidecar && npm ci --unsafe-perm

sudo npm install -g pino-pretty pm2 pm2-logrotate gulp grunt

if [[ "$DISTRO" == rhel* ]]; then
  sudo pm2 install pm2-logrotate
  sudo pm2 set pm2-logrotate:max_size 1G
  sudo pm2 set pm2-logrotate:retain 5
  sudo pm2 set pm2-logrotate:compress true
  sudo chown -R ec2-user:ec2-user  $HOME/apps
else
  sudo -u admin bash -c "pm2 install pm2-logrotate"
  sudo -u admin bash -c "pm2 set pm2-logrotate:max_size 1G"
  sudo -u admin bash -c "pm2 set pm2-logrotate:retain 5"
  sudo -u admin bash -c "pm2 set pm2-logrotate:compress true"
  sudo chown -R admin:admin  $HOME/apps
fi
