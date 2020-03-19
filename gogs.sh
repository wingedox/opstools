#!/bin/bash
source env.sh


echo "Install go..."
cd "$tmp_path"
if [ ! -d ${local_path}/go ]; then
  wget https://dl.google.com/go/go${go_ver}.linux-amd64.tar.gz
  sudo tar -C ${local_path} -xzf go${go_ver}.linux-amd64.tar.gz
  ln -s ${local_path}/go/bin/go $bin_path/go
fi


echo "Instll gogs binary..."
cd "$tmp_path"
if [ ! -d ${local_path}/gogs ]; then
  wget https://dl.gogs.io/${gogs_ver}/gogs_${gogs_ver}_linux_amd64.tar.gz
  sudo tar -C $local_path -xzf gogs_${gogs_ver}_linux_amd64.tar.gz
fi


echo "Create Service"
cat > /etc/systemd/system/gogs.service << EOF
[Unit]
Description=Gogs (Go Git Service)
After=syslog.target
After=network.target

[Service]
Type=simple
User=$user
ExecStart=$local_path/gogs/gogs web
ExecStop=kill -9 -f $local_path/gogs/gogs
WorkingDirectory=$local_path/gogs
Environment=USER=$user HOME=$main_path/home

[Install]
WantedBy=multi-user.target
EOF


# 启动服务
# =====================
echo "Run gogs.service"
systemctl daemon-reload
systemctl enable gogs.service
systemctl start gogs.service


# 配置 nginx
# =====================

cat > ${conf_path}/nginx/sites-available/gogs << EOF
upstream git {
    server 127.0.0.1:3000;
}

server {
    listen       80;
    server_name  git.qsopen.com;

    proxy_read_timeout 3600s;
    proxy_connect_timeout 3600s;
    proxy_send_timeout 3600s;

    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Real-IP $remote_addr;

    location / {
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;

        proxy_pass   http://git;
    }
}
EOF
ln -s $conf_path/nginx/sites-available/gogs $conf_path/nginx/sites-enabled/gogs
service nginx reload
