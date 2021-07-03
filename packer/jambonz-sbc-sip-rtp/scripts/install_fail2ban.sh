#!/bin/bash

sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo bash -c "cat >> /etc/fail2ban/jail.local" << EOF


[drachtio-tcp]
maxretry = 1
bantime = 86400
enabled  = true
filter   = drachtio
port     = 5060
protocol = tcp
logpath  = /var/log/drachtio/drachtio.log

[drachtio-udp]
maxretry = 1
bantime = 86400
enabled  = true
filter   = drachtio
port     = 5060
protocol = udp
logpath  = /var/log/drachtio/drachtio.log

EOF

sudo cp /tmp/drachtio-fail2ban.conf /etc/fail2ban/filter.d/drachtio.conf
sudo chmod 0644 /etc/fail2ban/filter.d/drachtio.conf

# add nginx jails and filters
sudo cp /tmp/nginx-noscript.jail /etc/fail2ban/jail.d/nginx-noscript.conf
sudo cp /tmp/nginx-noproxy.jail /etc/fail2ban/jail.d/nginx-noproxy.conf
sudo cp /tmp/nginx-nohome.jail /etc/fail2ban/jail.d/nginx-nohome.conf
sudo cp /tmp/nginx-badbots.jail /etc/fail2ban/jail.d/nginx-badbots.conf

sudo cp /tmp/nginx-noscript.filter /etc/fail2ban/filter.d/nginx-noscript.conf
sudo cp /tmp/nginx-noproxy.filter /etc/fail2ban/filter.d/nginx-noproxy.conf
sudo cp /tmp/nginx-nohome.filter /etc/fail2ban/filter.d/nginx-nohome.conf
sudo cp /tmp/nginx-badbots.filter /etc/fail2ban/filter.d/nginx-badbots.conf

sudo chmod 0644 /etc/fail2ban/jail.d/*.conf
sudo chmod 0644 /etc/fail2ban/filter.d/*.conf

sudo systemctl enable fail2ban
sudo systemctl restart fail2ban
