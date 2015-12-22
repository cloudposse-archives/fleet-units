changequote({{,}})dnl
define(NGINX_NAME, {{nginx}})dnl
define(UPSTREAM_NAME, haproxy)dnl
define(UPSTREAM_PATH, )dnl
define(UPSTREAM_SERVICE, {{UPSTREAM_NAME}}.service)dnl
define(UPSTREAM_SERVER, )dnl
define(SERVER_NAME, localhost)dnl
define(WEB_SOCKETS, {{false}})dnl
define(UPSTREAM_HEALTH_CHECK_URI, /)dnl
define(UPSTREAM_HEALTH_CHECK_HOST, localhost)dnl
define(UPSTREAM_HEALTH_CHECK, interval=10000 rise=2 fall=5 timeout=5000 type=http)dnl

[Install]
WantedBy=UPSTREAM_SERVICE

[Unit]
Description=Nginx Upstream Service for UPSTREAM_NAME on NGINX_NAME
Requires=etcd2.service
After=etcd2.service
Requires=docker.service
After=docker.service
Requires=flanneld.service
After=flanneld.service
After=UPSTREAM_SERVICE

[Service]
User=core
EnvironmentFile=/etc/environment
EnvironmentFile=/etc/env.d/*
Type=oneshot
RemainAfterExit=true

ExecStart=/usr/bin/etcdctl     set "/nginx/NGINX_NAME/config/UPSTREAM_NAME/server/server_name" "SERVER_NAME"
ExecStartPost=/usr/bin/etcdctl set "/nginx/NGINX_NAME/config/UPSTREAM_NAME/upstream/check" "UPSTREAM_HEALTH_CHECK"
ExecStartPost=/usr/bin/etcdctl set "/nginx/NGINX_NAME/config/UPSTREAM_NAME/upstream/check_http_send" "HEAD UPSTREAM_HEALTH_CHECK_URI HTTP/1.1\\r\\nHost: UPSTREAM_HEALTH_CHECK_HOST\\r\\nConnection: keep-alive\\r\\n\\r\\n"
ExecStartPost=/usr/bin/etcdctl set "/nginx/NGINX_NAME/config/UPSTREAM_NAME/upstream/check_http_expect_alive" "http_2xx http_3xx"
ExecStartPost=/usr/bin/etcdctl set "/nginx/NGINX_NAME/config/UPSTREAM_NAME/upstream/keepalive" "30"
ExecStartPost=/usr/bin/etcdctl set "/nginx/NGINX_NAME/config/UPSTREAM_NAME/path" "UPSTREAM_PATH"

dnl ifelse(UPSTREAM_SERVER, {{}}, {{}}, ExecStartPost=/usr/bin/etcdctl set "/nginx/{{NGINX_NAME}}/config/{{UPSTREAM_NAME}}/upstream/server/{{UPSTREAM_NAME}}" "{{UPSTREAM_SERVER}}")
dnl ifelse(UPSTREAM_SERVER, {{}}, {{}}, ExecStartPost=/usr/bin/etcdctl set "/nginx/{{NGINX_NAME}}/config/{{UPSTREAM_NAME}}/server/proxy_pass" "{{UPSTREAM_SERVER}}")
 
ifelse(WEB_SOCKETS, {{true}}, ExecStartPost=/usr/bin/etcdctl set /nginx/{{NGINX_NAME}}/config/{{UPSTREAM_NAME}}/server/location/web_sockets "{{{{true}}}}", {{}})

# Deregister the service
#ExecStop=-/usr/bin/etcdctl rm /nginx/NGINX_NAME/config/UPSTREAM_NAME/server/proxy_pass
#ExecStop=-/usr/bin/etcdctl rm --recursive /nginx/NGINX_NAME/config/UPSTREAM_NAME/upstream/


