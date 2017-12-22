#!/bin/bash

# Swap
if [ -n $(swapon -s) ]; then
  ramSize=$(free -m | grep -oP '\d+' | head -n 1)
  fallocate -l $(($ramSize * 2))m /swap
  chmod 0600 /swap
  mkswap /swap
  swapon /swap
  echo "/swap none swap sw 0 0" >> /etc/fstab
fi

# Unnneeded stuff to increase memory
apt autoremove -y \
  snapd mdadm lvm2 open-iscsi \
  docker docker-engine docker.io \
  lxd liblxc1 lxc-common lxcfs lxd-client

# Upgrade
apt update
apt upgrade -y

# Docker
apt install -y apt-transport-https ca-certificates curl software-properties-common
if ! apt-key list | grep -i docker; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  apt-key fingerprint 0EBFCD88
fi
apt-cache policy | grep -i docker || add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
apt install -y docker-ce

