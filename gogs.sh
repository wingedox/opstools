#!/bin/bash
source env.sh


echo "Install go..."
cd "$tmp_path"
if [ ! -d ${local_path}/go ]; then
  wget https://dl.google.com/go/go${go_ver}.linux-amd64.tar.gz
  sudo tar -C ${local_path} -xzf go${go_ver}.linux-amd64.tar.gz
  ln -s ${local_path}/go/bin/go $bin_path/go
fi


echo "Instll gogs..."
cd "$tmp_path"
if [ ! -d ${local_path}/gogs ]; then
  wget https://dl.gogs.io/${gogs_ver}/gogs_${gogs_ver}_linux_amd64.tar.gz
  sudo tar -C $local_path -xzf gogs_${gogs_ver}_linux_amd64.tar.gz
  ln -s ${local_path}/gogs/gogs $bin_path/gogs
fi

echo "create git user"
create_user git