#!/usr/bin/env bash
source ini.sh

force=$1
main_path=/opt/${user}

if [ "$force" == "force" ]; then
  rm -rf $main_path
  fi

tmp_path=/opt/tmp
local_path=${main_path}/local
bin_path=${main_path}/bin

# datas folder
conf_path=${main_path}/conf
log_path=${main_path}/logs
data_path=${main_path}/data

# local backup folder
backup_path=${main_path}/backup

# backup server folder
client_backup=/opt/backup

mkfolder(){
	folders=$1
	for folder in ${folders[*]}; do
		[ ! -d "${folder}" ] && mkdir -p "${folder}" && echo "Create $folder..."
	done
}

mkfolder "$main_path $tmp_path $local_path $bin_path $conf_path $log_path $data_path"

if ! grep -q "$bin_path" /etc/profile; then
  echo "export PATH=\$PATH:$bin_path" >> /etc/profile
  source /etc/profile
  fi


# create gruup if not exists
create_group(){
  # create group if not exists
  group=$1
  grep -E "^$group" /etc/group >& /dev/null
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
  create_group "$g"
  egrep "^$u" /etc/passwd >& /dev/null
  if [ $? -ne 0 ]; then
      useradd -s /sbin/nologin -g $g $u
    fi
}

create_group "$group"
egrep "^$user" /etc/passwd >& /dev/null
if [ $? -ne 0 ]
then
    useradd -m -s /sbin/nologin -d /opt/"$user"/home -g "$group" "$user"
fi

#日志名称
log_file="${log_path}/opstools.log"  #操作日志存放路径
fsize=2000000
exec 2>>$log_file  #如果执行过程中有错误信息均输出到日志文件中

#日志函数
#参数
  #参数一，级别，INFO ,WARN,ERROR
    #参数二，内容
#返回值
function log()
{
  #判断格式
  if [ 2 -gt $# ]
  then
    echo "parameter not right in log function" ;
    return ;
  fi
  if [ -e "$log_file" ]
  then
    touch "$log_file"
  fi

  local curtime;
  curtime=$(date +"%Y-%m-%d %H:%M:%S")

  local cursize ;
  cursize=$(cat "$log_file" | wc -c) ;

  if [ $fsize -lt $cursize ]
  then
    mv "$log_file" "$(date +"%Y%m%d%H%M%S").out"
    touch "$log_file" ;
  fi
  echo "$curtime $*" >> "$log_file";
}