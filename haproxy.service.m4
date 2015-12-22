changequote({{,}})dnl
define(FLEET_GLOBAL_SERVICE, true)dnl
define(DOCKER_IMAGE, cloudposse/library:haproxy)dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl
define(DOCKER_NAME, haproxy)dnl
define(HAPROXY_PORT, 7000)dnl
define(HAPROXY_ADMIN_PORT, 8192)dnl
define(DNS_SERVICE_NAME, haproxy)dnl
define(DNS_SERVICE_ID, %H)dnl
 
[Unit]
Description=HAProxy Server
Requires=docker.service
After=docker.service
Requires=flanneld.service
After=flanneld.service


[Service]
User=core
TimeoutStartSec=0
EnvironmentFile=/etc/environment
EnvironmentFile=/etc/env.d/*
ExecStartPre=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStartPre=-/usr/bin/docker rm DOCKER_NAME
ExecStartPre=-/usr/bin/docker --debug=true pull DOCKER_IMAGE
ExecStart=/usr/bin/docker run \
                          --rm \
                          --name DOCKER_NAME \
                          -p HAPROXY_PORT:9000 \
                          -p HAPROXY_ADMIN_PORT:9001 \
                          -e "SERVICE_NAME=DNS_SERVICE_NAME" \
                          -e "SERVICE_ID=DNS_SERVICE_ID" \
                          DOCKER_IMAGE 
ExecStop=/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStopPost=-/usr/bin/docker rm DOCKER_NAME
TimeoutStopSec=DOCKER_STOP_TIMEOUT{{s}}
RestartSec=5s
Restart=always

[X-Fleet]
Global=FLEET_GLOBAL_SERVICE
