changequote({{,}})dnl
define(NGINX_NAME, {{nginx}})dnl
define(NGINX_SERVICE, {{NGINX_NAME.service}})dnl
define(NGINX_PATH, /nginx/{{NGINX_NAME}})dnl
define(DOCKER_NAME, nginx-confd)dnl
define(DOCKER_REGISTRY, index.docker.io)dnl
define(DOCKER_REPOSITORY, cloudposse/nginx-confd)dnl
define(DOCKER_TAG, latest)dnl
define(DOCKER_IMAGE, {{DOCKER_REGISTRY}}/{{DOCKER_REPOSITORY}}:{{DOCKER_TAG}})dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl
define(DOCKER_DNS, ${DNS_SERVER})dnl
define(DOCKER_DNS_SEARCH, )dnl
define(CONFD_INTERVAL, 15)dnl
define(CONFD_PREFIX, /)dnl
define(GA_TRACKING_ID, -)dnl

[Install]
WantedBy=NGINX_SERVICE

[Unit]
Description=Nginx Configuration Service
#Requires=docker.service
#After=docker.service
#Requires=flanneld.service
#After=flanneld.service
#Requires=etcd2.service
#After=etcd2.service
#BindTo=etcd2.service

# Our data volume must be ready
After=NGINX_SERVICE
#BindTo=NGINX_SERVICE
PartOf=NGINX_SERVICE

[Service]
User=core
EnvironmentFile=/etc/environment
EnvironmentFile=/etc/env.d/*

# Kill any existing discovery service
ExecStartPre=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStartPre=-/usr/bin/docker rm DOCKER_NAME

# preload container...this ensures we fail if our registry is down and we can't obtain the build we're expecting
ExecStartPre=-/usr/bin/docker --debug=true pull DOCKER_IMAGE

# We need to provide our confd container with the IP it can reach etcd
# on, the docker socket so it send HUP signals to nginx
ExecStart=/usr/bin/docker run \
                          --name DOCKER_NAME \
                          ifelse(DOCKER_DNS, {{}}, {{}}, --dns={{DOCKER_DNS}}) \
                          ifelse(DOCKER_DNS_SEARCH, {{}}, {{}}, --dns-search={{DOCKER_DNS_SEARCH}}) \
                          --rm \
                          -v /var/run/docker.sock:/var/run/docker.sock \
                          --volumes-from=NGINX_NAME \
                          -e "{{DOCKER_DNS}}=DOCKER_DNS" \
                          -e "ETCD_HOST=${COREOS_PRIVATE_IPV4}" \
                          -e "{{CONFD_INTERVAL}}=CONFD_INTERVAL" \
                          -e "{{CONFD_PREFIX}}=CONFD_PREFIX" \
                          -e "{{NGINX_NAME}}=NGINX_NAME" \
                          -e "{{NGINX_PATH}}=NGINX_PATH" \
                          -e "{{GA_TRACKING_ID}}=GA_TRACKING_ID" \
                          DOCKER_IMAGE

ExecStop=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME

Restart=always
TimeoutStartSec=0
TimeoutStopSec=20s
RestartSec=15s

[X-Fleet]
Global=true

