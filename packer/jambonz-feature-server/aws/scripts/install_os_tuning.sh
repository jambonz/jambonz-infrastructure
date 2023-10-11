#!/bin/bash
DISTRO=$1

export PATH=/usr/local/bin:$PATH

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

if [[ "$DISTRO" == rhel* ]] ; then
  grep -q "* soft core unlimited" /etc/security/limits.conf
  if [ $? -ne 0 ]; then
    echo "* soft core unlimited" | sudo tee -a /etc/security/limits.conf > /dev/null
  fi

  grep -q "* hard core unlimited" /etc/security/limits.conf
  if [ $? -ne 0 ]; then
    echo "* hard core unlimited" | sudo tee -a /etc/security/limits.conf > /dev/null
  fi
  ulimit -c unlimited
else
  sudo cp /tmp/20auto-upgrades /etc/apt/apt.conf.d/20auto-upgrades
fi

# disable ipv6
echo "net.ipv6.conf.all.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf > /dev/null
echo "net.ipv6.conf.default.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf > /dev/null

# install latest cmake
if [ "$DISTRO" == "debian-12" ] || [[ "$DISTRO" == rhel* ]] ; then
  echo disable RHEL firewall
  sudo systemctl stop firewalld
  sudo systemctl disable firewalld

  echo build cmake 3.27, required by bcg729
  cd /usr/local/src
  wget https://github.com/Kitware/CMake/archive/refs/tags/v3.27.4.tar.gz
  tar xvfz v3.27.4.tar.gz
  cd CMake-3.27.4
  echo "building cmake"
  ./bootstrap && make -j 8 && sudo make install
  echo "cmake built and installed"
  export PATH=/usr/local/bin:$PATH
  cmake --version
fi