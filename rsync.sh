#!/usr/bin/env bash
source env.sh

rsync_remote(){
  rsync_remote=$1
  rsync_folder=$2

  backup_to=$(eval echo "${client_backup}/${rsync_remote}${rsync_folder}")
  mkfolder "${backup_to}"
  log INFO "Backup ${rsync_remote}:$rsync_folder to ${backup_to}"
  rsync -avz -e 'ssh' "${rsync_remote}":"$rsync_folder" "${backup_to}"
}

# backup local host
if [ -f "${backup_path}/backup" ]; then
  for folder in $(cat "${backup_path}/backup"); do
    backup_to=$(eval echo "${client_backup}/${local_host}${folder}")
    mkfolder "${backup_to}"
    log INFO "Backup ${folder} to ${backup_to}"
    rsync -avz "$folder" "${backup_to}"
    done
  else
    log WARN "The file ${backup_path}/backup not found on localhost."
  fi

for remote in ${hosts}; do
  if [ "$(ssh "$remote" "[ -f ${backup_path}/backup ] && echo 'ok'")" == 'ok' ]; then
    backups=$(ssh "$remote" "cat ${backup_path}/backup")

    for folder in $backups; do
      rsync_remote "$remote" "$folder"
      done
    else
      log WARN "The file ${backup_path}/backup not found on ${remote}."
    fi
  done
