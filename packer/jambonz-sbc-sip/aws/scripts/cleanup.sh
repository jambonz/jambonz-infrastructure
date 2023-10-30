#! /bin/bash
LEAVE_SOURCE=$1
DISTRO=$2

set -e
set -x

if [ "$DISTRO" == "rhel-9" ]; then
  sudo dnf install -y iptables-services
else
  echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
  echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
  sudo apt-get -y install iptables-persistent
  sudo rm /root/.ssh/authorized_keys
  sudo rm ~/.ssh/authorized_keys
fi

sudo rm -Rf /tmp/*
if [ "$LEAVE_SOURCE" = 'no' ]; then sudo rm -Rf /usr/local/src/*; fi
