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

sudo systemctl enable fail2ban
sudo systemctl restart fail2ban
