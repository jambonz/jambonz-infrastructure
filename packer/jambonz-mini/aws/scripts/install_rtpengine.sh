#!/bin/bash
VERSION=$2
DISTRO=$1

echo "rtpengine version to install is ${VERSION} on distribution ${DISTRO}"

if [[ "$DISTRO" == rhel* ]]; then
   if [ "$EUID" -ne 0 ]; then
      echo "Switching to root user..."
      sudo bash "$0" --as-root
      exit
   fi

   # Your script continues here, as root
   echo "Now running as root user"
   setenforce 0
   export PATH=/usr/local/bin:$PATH
   export PATH=/usr/local/bin:$PATH
   export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
   export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
fi

cd /usr/local/src
git clone https://github.com/BelledonneCommunications/bcg729.git
cd bcg729
cmake . -DCMAKE_INSTALL_PREFIX=/usr && make && sudo make install chdir=/usr/local/src/bcg729
cd /usr/local/src

git clone https://github.com/warmcat/libwebsockets.git -b v4.3.2
cd /usr/local/src/libwebsockets
mkdir -p build && cd build && cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo && make && sudo make install

cd /usr/local/src
git clone https://github.com/sipwise/rtpengine.git -b ${VERSION}
cd rtpengine

if [[ "$DISTRO" == rhel* ]]; then
  echo with_iptables_option=no with_transcoding=yes make
  make with_iptables_option=no with_transcoding=yes -j 8
  cp /usr/local/src/rtpengine/daemon/rtpengine /usr/local/bin
  mv /tmp/rtpengine-nomodule.service /etc/systemd/system/rtpengine.service
  chmod 644 /etc/systemd/system/rtpengine.service
  systemctl enable rtpengine
  systemctl start rtpengine
else
  echo make with_transcoding=yes with_iptables_option=yes with-kernel
  make with_transcoding=yes with_iptables_option=yes with-kernel

  # copy iptables extension into place
  cp ./iptables-extension/libxt_RTPENGINE.so `pkg-config xtables --variable=xtlibdir`
  mkdir -p /lib/modules/`uname -r`/updates/
  cp ./kernel-module/xt_RTPENGINE.ko /lib/modules/`uname -r`/updates
  depmod -a
  modprobe xt_RTPENGINE
  cat << EOF >> /etc/modules
xt_RTPENGINE
EOF

  echo 'add 42' > /proc/rtpengine/control
  iptables -I INPUT -p udp --dport 40000:60000 -j RTPENGINE --id 42

  cp /usr/local/src/rtpengine/daemon/rtpengine /usr/local/bin
  cp /usr/local/src/rtpengine/recording-daemon/rtpengine-recording /usr/local/bin/
  sudo mv /tmp/rtpengine.service /etc/systemd/system
  sudo chmod 644 /etc/systemd/system/rtpengine.service
  sudo systemctl enable rtpengine
  sudo systemctl start rtpengine
fi


if [[ "$DISTRO" == rhel* ]]; then
  echo "not installing recording service"
else
  sudo mv /tmp/rtpengine-recording.service /etc/systemd/system
  sudo mv /tmp/rtpengine-recording.ini /etc/rtpengine-recording.ini
  sudo chmod 644 /etc/systemd/system/rtpengine-recording.service
  sudo chmod 644 /etc/rtpengine-recording.ini
  mkdir -p /var/spool/recording
  mkdir -p /recording
  sudo systemctl enable rtpengine-recording
  sudo systemctl start rtpengine-recording
fi
