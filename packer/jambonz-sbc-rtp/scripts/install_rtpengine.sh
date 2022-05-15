#!/bin/bash
VERSION=$1

echo "rtpengine version to install is ${VERSION}"

# install linux headers
apt-get install linux-headers-$(uname -r)

cd /usr/local/src
git clone https://github.com/BelledonneCommunications/bcg729.git
cd bcg729
cmake . -DCMAKE_INSTALL_PREFIX=/usr && make && sudo make install chdir=/usr/local/src/bcg729
cd /usr/local/src

git clone https://github.com/warmcat/libwebsockets.git -b v3.2.3
cd /usr/local/src/libwebsockets
sudo mkdir -p build && cd build && sudo cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo && sudo make && sudo make install

cd /usr/local/src
git clone https://github.com/sipwise/rtpengine.git -b ${VERSION}
cd rtpengine
make with_transcoding=yes with_iptables_option=yes with-kernel

# copy iptables extension into place
cp ./iptables-extension/libxt_RTPENGINE.so `pkg-config xtables --variable=xtlibdir`

# install kernel module
mkdir /lib/modules/`uname -r`/updates/
cp ./kernel-module/xt_RTPENGINE.ko /lib/modules/`uname -r`/updates
depmod -a
modprobe xt_RTPENGINE
echo 'add 42' > /proc/rtpengine/control
iptables -I INPUT -p udp --dport 40000:60000 -j RTPENGINE --id 42

cp /usr/local/src/rtpengine/daemon/rtpengine /usr/local/bin
sudo mv /tmp/rtpengine.service /etc/systemd/system
sudo chmod 644 /etc/systemd/system/rtpengine.service
sudo systemctl enable rtpengine
sudo systemctl start rtpengine
