#!/usr/bin/env bash
source rsync.sh


create_folder ${log_path}/rsync

cat > ${conf_path}/rsync << EOF
uid = ${user}
gid = ${group}
use chroot = no

max connections = 200
timeout = 300
pid file = ${log_path}/rsync/rsyncd.pid
lock file = ${log_path}/rsync/rsync.lock
log file = ${log_path}/rsync/rsyncd.log

ignore errors
read only = false
truelist = false
auth users = rsync_backup
secrets file = ${conf_path}/rsync/rsync.password

[git_repo]
dont compress  = *.gz *.tgz *.zip *.z *.Z *.rpm *.deb *.bz2
path = ${main_path}/backup/git_qsopen_com_repo
EOF


cat > ${conf_path}/rsync/rsync.password << EOF
rsync_backup:${rsync_password}
EOF


chmod 600 ${conf_path}/rsync/rsync.password