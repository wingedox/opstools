#!/bin/bash
source ini.sh

force=$1
main_path=/opt/${user}

if [ "$force" == "force" ]; then
  rm -rf $main_path
  fi

tmp_path=${main_path}/tmp
local_path=${main_path}/local
bin_path=${main_path}/bin
conf_path=${main_path}/conf
log_path=${main_path}/log
data_path=${main_path}/data


mkfolder(){
	folders=$1
	for folder in ${folders[*]}; do
		[ ! -d "${folder}" ] && mkdir -p "${folder}" && echo "Create $folder..."
	done
}

mkfolder "$main_path $tmp_path $local_path $bin_path $conf_path $log_path $data_path"

if ! grep -q $bin_path /etc/profile; then
  echo "export PATH=\$PATH:$bin_path" >> /etc/profile
  source /etc/profile
  fi


# create gruup if not exists
create_group(){
  # create group if not exists
  group=$1
  egrep "^$group" /etc/group >& /dev/null
  if [ $? -ne 0 ]; then
    groupadd $group
    fi
}


# create user if not exists
create_user(){
  u=$1
  g=$1
  if [ $# -eq 2 ]; then
      g=$2
    fi
  create_group $g
  egrep "^$u" /etc/passwd >& /dev/null
  if [ $? -ne 0 ]; then
      useradd -s /sbin/nologin -g $g $u
    fi
}

create_group $group
egrep "^$user" /etc/passwd >& /dev/null
if [ $? -ne 0 ]
then
    useradd -m -s /sbin/nologin -d /opt/$user/home -g $group $user
fi

