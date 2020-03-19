#!/usr/bin/env bash
user=qs
group=qs

nginx_ver=1.17.9
go_ver=1.14
gogs_ver=0.11.91
rsync_ver=3.1.3

# backup
host_repo=git.qsopen.com
host_live=xy.qsodoo.com
host_dev=dev.qsopen.com

local_host=$host_repo
hosts="${host_live} ${host_repo} ${host_dev}"