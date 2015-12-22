changequote({{,}})dnl
define(UPSTREAM_NAME, default)dnl
define(UPSTREAM_SERVER, localhost:8080)dnl
define(NGINX_NAME, nginx)dnl

[Unit]
Description=Nginx Upstream Server (UPSTREAM_SERVER) for UPSTREAM_NAME available on NGINX_NAME
Requires=docker.service
After=docker.service
Requires=flanneld.service
After=flanneld.service
After=etcd2.service
Requires=etcd2.service

[Service]
TimeoutStartSec=0
User=core
EnvironmentFile=/etc/environment
EnvironmentFile=/etc/env.d/*
Type=oneshot
RemainAfterExit=yes

ExecStart=/usr/bin/etcdctl set /nginx/NGINX_NAME/config/UPSTREAM_NAME/upstream/server/%m UPSTREAM_SERVER

# Deregister the service
ExecStop=/usr/bin/etcdctl rm /nginx/NGINX_NAME/config/UPSTREAM_NAME/upstream/server/%m

[Install]
WantedBy=multi-user.target

