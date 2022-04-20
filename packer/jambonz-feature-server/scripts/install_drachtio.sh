#!/bin/bash
VERSION=$1

echo "drachtio version to install is ${VERSION}"

chmod 0777 /usr/local/src
cd /usr/local/src
git clone https://github.com/drachtio/drachtio-server.git -b ${VERSION}
cd drachtio-server
git submodule update --init --recursive
./autogen.sh && mkdir -p build && cd $_ && ../configure CPPFLAGS='-DNDEBUG -g -O0' && make -j 4 && sudo make install

sudo mv /tmp/drachtio.conf.xml /etc
sudo mv /tmp/drachtio.service /etc/systemd/system
sudo chmod 644 /etc/drachtio.conf.xml
sudo chmod 644 /etc/systemd/system/drachtio.service
sudo systemctl enable drachtio
sudo systemctl restart drachtio
