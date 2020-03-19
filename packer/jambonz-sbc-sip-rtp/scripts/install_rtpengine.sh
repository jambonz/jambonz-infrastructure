#!/bin/bash
VERSION=$1

echo "rtpengine version to install is ${VERSION}"

cd /usr/local/src
git clone https://github.com/BelledonneCommunications/bcg729.git
cd bcg729
cmake . -DCMAKE_INSTALL_PREFIX=/usr && make && sudo make install chdir=/usr/local/src/bcg729
cd /usr/local/src
git clone https://github.com/sipwise/rtpengine.git -b ${VERSION}
cd rtpengine/daemon
make with_transcoding=yes
cp /usr/local/src/rtpengine/daemon/rtpengine /usr/local/bin
sudo mv /tmp/rtpengine.service /etc/systemd/system
sudo chmod 644 /etc/systemd/system/rtpengine.service
sudo systemctl enable rtpengine
