#!/usr/bin/env bash
source env.bash

cd $(temp_path)
if [ -d ${temp_path}/ ]; then
  wget https://download.samba.org/pub/rsync/src/rsync-${rsync_ver}.tar.gz
  tar -zxvf rsync-${rsync_ver}.tar.gz
  cd ${temp_path}-3.1.3/ || exit
  ./configure --prefix=${local_path}/rsync --disable-ipv6
  make && make install
  ln -s ${local_path}/rsync/bin/rsync ${bin_path}/rsync
  fi
