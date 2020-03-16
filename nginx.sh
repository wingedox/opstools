#!/bin/bash
source env.sh

create_site(){
name=$1
domain=$2
port=$3

echo "Create site: $name"
site_file=$conf_path/nginx/sites-available/$name
if [ -f $site_file ]; then
    return 1
fi

cat > $site_file << EOF
upstream $name {
    server 127.0.0.1:$port;
}

server {
    listen       80;
    server_name  $domain;

    proxy_set_header Host \$host;
    proxy_set_header X-Forwarded-Host \$host;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header X-Real-IP \$remote_addr;

    location / {
        proxy_pass   http://$name;
    }
}
EOF
}

echo "Install depends..."
apt update

# 源码安装 nginx
# 依赖
# =====================
apt install -y gcc make
apt install -y libpcre3 libpcre3-dev
apt install -y openssl libssl-dev
apt install -y zlib1g-dev

# 下载源码
# =====================
echo "Download nginx source..."
cd $tmp_path || exit
if [ ! -f "nginx-$nginx_ver.tar.gz" ]; then
  wget http://nginx.org/download/nginx-$nginx_ver.tar.gz || exit
  fi
if [ ! -d "nginx-$nginx_ver" ]; then
  tar -xzf nginx-"$nginx_ver".tar.gz
  fi

cd nginx-"$nginx_ver" || exit

# 编译
# =====================
echo "Start Complie..."
nginx_user=root
mkfolder "$log_path/nginx $conf_path/nginx"

if [ ! -f ${bin_path}/nginx ]; then
./configure --prefix=${local_path}/nginx \
      --sbin-path=${bin_path} \
      --pid-path=${log_path}/nginx/nginx.pid \
	    --conf-path=${conf_path}/nginx/nginx.conf \
	    --error-log-path=${log_path}/nginx/error.log \
	    --http-log-path=${log_path}/nginx/access.log \
	    --group=$group \
	    --with-http_gzip_static_module \
	    --with-http_ssl_module \
	    --with-http_v2_module \
	    --with-pcre-jit

make && make install
if [ ! $? -eq 0 ]; then
  echo 'Complie error.'
  exit
fi
fi
# 配置
# =====================

mkfolder "$conf_path/nginx/sites-enabled $conf_path/nginx/sites-available"

echo "Create nginx.conf"
cat > $conf_path/nginx/nginx.conf << EOF
user  $nginx_user;
worker_processes  4;

# [debug | info | notice | warn | error | crit | alert | emerg]
error_log  $log_path/nginx/error.log error;
pid        $log_path/nginx/nginx.pid;

events {
    worker_connections  1024;
}



http {
    include       mime.types;
    default_type  application/octet-stream;

    sendfile        on;

    keepalive_timeout  65;
    client_max_body_size 20480m;
    gzip  on;

    include $conf_path/nginx/sites-enabled/*;
}
EOF


# 创建服务
# =====================
echo "Cretae nginx.service"
cat > /etc/systemd/system/nginx.service << EOF
[Unit]
Description=The NGINX HTTP and reverse proxy server
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=${log_path}/nginx/nginx.pid
ExecStartPre=${bin_path}/nginx -t -c ${conf_path}/nginx/nginx.conf
ExecStart=${bin_path}/nginx -c ${conf_path}/nginx/nginx.conf
ExecReload=${bin_path}/nginx -s reload
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

# 运行
# =====================
echo "Run nginx.service"
systemctl daemon-reload
systemctl enable nginx.service
systemctl start nginx.service


# 建站
# =====================
create_site qs13 \*.qs13.dev.qsopen.com 10909
ln -s $conf_path/nginx/sites-available/qs13 $conf_path/nginx/sites-enabled/qs13
service nginx reload