#!/bin/bash
cd /usr/local/src/
git clone https://github.com/palner/apiban.git
sudo mkdir /usr/local/bin/apiban && sudo chmod 0755 /usr/local/bin/apiban
sudo cp -r /usr/local/src/apiban/clients/go/apiban-iptables-client /usr/local/bin/apiban && sudo chmod +x /usr/local/bin/apiban/apiban-iptables-client
sudo cp /tmp/config.json /usr/local/bin/apiban/config.json
sudo chmod 0644 /usr/local/bin/apiban/config.json
sudo cp /tmp/apiban.logrotate /etc/logrotate.d/apiban-client
sudo chmod 0644 /etc/logrotate.d/apiban-client
echo "*/4 * * * * root cd /usr/local/bin/apiban && ./apiban-iptables-client >/dev/null 2>&1" | sudo tee -a /etc/crontab
