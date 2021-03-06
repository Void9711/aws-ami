#!/bin/bash

#
# Right now the default apt sources in China regions are located in UK and US:
#   cn-north-1a.clouds.archive.ubuntu.com
#   cn-north-1b.clouds.archive.ubuntu.com
#
# So we change apt sources to domestic mirrors, if in China regions.
# This will significantly speed-up all apt-related operations.
#

set -e

function change_apt_sources {
  local readonly codename=$(lsb_release -cs)
  echo 'Changing apt sources to mirrors.aliyun.com'
  sudo mv /etc/apt/sources.list /etc/apt/sources.list.original
  sudo tee /etc/apt/sources.list << EOF
deb http://mirrors.aliyun.com/ubuntu/ ${codename} main restricted
deb http://mirrors.aliyun.com/ubuntu/ ${codename}-updates main restricted
deb http://mirrors.aliyun.com/ubuntu/ ${codename} universe
deb http://mirrors.aliyun.com/ubuntu/ ${codename}-updates universe
deb http://mirrors.aliyun.com/ubuntu/ ${codename} multiverse
deb http://mirrors.aliyun.com/ubuntu/ ${codename}-updates multiverse
deb http://mirrors.aliyun.com/ubuntu/ ${codename}-backports main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu ${codename}-security main restricted
deb http://security.ubuntu.com/ubuntu ${codename}-security universe
deb http://security.ubuntu.com/ubuntu ${codename}-security multiverse
EOF
}

function preserve_apt_sources_list {
  echo 'Telling cloud-init to preserve existing /etc/apt/sources.list'
  echo 'apt_preserve_sources_list: true' | sudo tee /etc/cloud/cloud.cfg.d/99_apt_preserve_sources_list.cfg
}

readonly az=$(ec2metadata --availability-zone)
if [[ $az == cn-* ]]; then
  change_apt_sources
  preserve_apt_sources_list
fi
