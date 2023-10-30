#! /bin/bash
DISTRO=$1
LEAVE_SOURCE=$2

set -e
set -x

echo "running cleanup.sh on $DISTRO, leaving source: $LEAVE_SOURCE"

if [[ "$DISTRO" == rhel* ]]; then
  sudo dnf install -y iptables-services
  sudo subscription-manager unregister
else
  echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
  echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
  sudo apt-get -y install iptables-persistent
  sudo rm /root/.ssh/authorized_keys
  sudo rm ~/.ssh/authorized_keys
fi

sudo rm -Rf /tmp/*
if [ "$LEAVE_SOURCE" = 'no' ]; then sudo rm -Rf /usr/local/src/*; fi
