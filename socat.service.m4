changequote({{,}})dnl
define(FLEET_GLOBAL_SERVICE, true)dnl
define(DOCKER_IMAGE, cloudposse/socat:latest)dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl
define(DOCKER_NAME, haproxy)dnl
define(DOCKER_PORT, 80:80/tcp)dnl
define(DOCKER_ARGS, -h)dnl
define(DOCKER_DNS, ${DNS_SERVER})dnl
define(DOCKER_DNS_SEARCH, )dnl
define(DNS_SERVICE_NAME, haproxy)dnl
define(DNS_SERVICE_ID, %H)dnl
 
[Unit]
Description=Socat Service
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
                          ifelse(DOCKER_DNS, {{}}, {{}}, --dns={{DOCKER_DNS}}) \
                          ifelse(DOCKER_DNS_SEARCH, {{}}, {{}}, --dns-search={{DOCKER_DNS_SEARCH}}) \
                          ifelse(DOCKER_PORT, {{}}, {{}}, -p {{DOCKER_PORT}}) \
                          -e "SERVICE_NAME=DNS_SERVICE_NAME" \
                          -e "SERVICE_ID=DNS_SERVICE_ID" \
                          DOCKER_IMAGE \
                          DOCKER_ARGS
ExecStop=/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStopPost=-/usr/bin/docker rm DOCKER_NAME
TimeoutStopSec=DOCKER_STOP_TIMEOUT{{s}}
RestartSec=5s
Restart=always

[X-Fleet]
Global=FLEET_GLOBAL_SERVICE
