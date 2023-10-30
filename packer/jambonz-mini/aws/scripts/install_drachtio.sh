#!/bin/bash
DISTRO=$1
VERSION=$2

echo "drachtio version to install is ${VERSION} on ${DISTRO}"

chmod 0777 /usr/local/src
cd /usr/local/src

git clone https://github.com/drachtio/drachtio-server.git -b ${VERSION}
cd drachtio-server
git submodule update --init --recursive
./autogen.sh && mkdir -p build && cd $_ && ../configure --enable-tcmalloc=yes CPPFLAGS='-DNDEBUG -g -O2' && make -j 8 && sudo make install

echo "installing drachtio for aws"

if [[ "$DISTRO" == rhel* ]]; then
  sudo mv /tmp/drachtio-rhel.service /etc/systemd/system/drachtio.service
  sudo mv /tmp/drachtio-rhel-5070.service /etc/systemd/system/drachtio-5070.service
else
  sudo mv /tmp/drachtio.service /etc/systemd/system
  sudo mv /tmp/drachtio-5070.service /etc/systemd/system
fi

sudo mv /tmp/drachtio.conf.xml /etc
sudo chmod 644 /etc/drachtio.conf.xml
sudo chmod 644 /etc/systemd/system/drachtio.service
sudo systemctl enable drachtio
sudo systemctl restart drachtio
sudo systemctl status drachtio.service

sudo mv /tmp/drachtio-5070.conf.xml /etc
sudo chmod 644 /etc/drachtio-5070.conf.xml
sudo chmod 644 /etc/systemd/system/drachtio-5070.service
sudo systemctl enable drachtio-5070
sudo systemctl restart drachtio-5070