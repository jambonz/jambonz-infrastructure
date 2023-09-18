#!/bin/bash
DISTRO=$1

sudo sed -i '/# End of file/i *                hard       nofile          65535'  /etc/security/limits.conf
sudo sed -i '/# End of file/i *                soft       nofile          65535'  /etc/security/limits.conf
sudo sed -i '/# End of file/i root             hard       nofile          65535'  /etc/security/limits.conf
sudo sed -i '/# End of file/i root             soft       nofile          65535'  /etc/security/limits.conf
sudo sed -i s/^#DefaultLimitNOFILE=.*$/DefaultLimitNOFILE=65535:65535/g /etc/systemd/system.conf

sudo bash -c 'cat >> /etc/sysctl.conf << EOT
net.core.rmem_max=26214400
net.core.rmem_default=26214400
vm.swappiness=0
vm.dirty_expire_centisecs=200
vm.dirty_writeback_centisecs=100
EOT'

sudo cp /tmp/20auto-upgrades /etc/apt/apt.conf.d/20auto-upgrades

# disable ipv6
echo "net.ipv6.conf.all.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf > /dev/null
echo "net.ipv6.conf.default.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf > /dev/null

# install latest cmake
if [ "$DISTRO" == "debian-12" ]; then
  cd /usr/local/src
  wget https://github.com/Kitware/CMake/archive/refs/tags/v3.27.4.tar.gz
  tar xvfz v3.27.4.tar.gz
  cd CMake-3.27.4
  ./bootstrap && make -j 4 && sudo make install
  cmake --version
fi