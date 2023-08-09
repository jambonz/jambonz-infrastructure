#!/bin/bash
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

# Fix locales
sudo bash -c 'cat >> /etc/default/locale << EOT
LANG="en_US.UTF-8"
LANGUAGE="en_US:en"
EOT'

sudo sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sudo dpkg-reconfigure --frontend=noninteractive locales
