changequote({{,}})dnl
define(DOCKER_NAME, redis)dnl
define(DOCKER_REGISTRY, index.docker.io)dnl
define(DOCKER_REPOSITORY, cloudposse/library)dnl
define(DOCKER_TAG, {{{{redis}}}})dnl
define(DOCKER_IMAGE, {{DOCKER_REGISTRY}}/{{DOCKER_REPOSITORY}}:{{DOCKER_TAG}})dnl
define(DOCKER_STOP_TIMEOUT, 120)dnl
define(DOCKER_DNS, ${DNS_SERVER})dnl
define(DOCKER_VOLUME, none)dnl
define(DOCKER_VOLUME_OCTAL_MODE, 1777)dnl
define(REDIS_PORT, )dnl
define(REDIS_MAXMEMORY, 64m)dnl
define(REDIS_MAXMEMORY_POLICY, volatile-lru)dnl
define(DNS_SERVICE_NAME, redis)dnl
define(DNS_SERVICE_ID, %H)dnl

[Unit]
Description=Redis Server
Requires=docker.service
After=docker.service
Requires=flanneld.service
After=flanneld.service


[Service]
User=core
EnvironmentFile=/etc/environment
EnvironmentFile=/etc/env.d/*
TimeoutStartSec=0
ifelse(DOCKER_VOLUME, {{none}}, {{}}, ExecStartPre=/usr/bin/sh -c "echo {{DOCKER_VOLUME}} | cut -d: -f1 | xargs mkdir -p -m {{DOCKER_VOLUME_OCTAL_MODE}}")
ExecStartPre=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStartPre=-/usr/bin/docker rm DOCKER_NAME
ExecStartPre=-/usr/bin/docker --debug=true pull DOCKER_IMAGE
ExecStart=/usr/bin/docker run \
                          --name DOCKER_NAME \
                          ifelse(DOCKER_DNS, {{}}, {{}}, --dns {{DOCKER_DNS}}) \
                          --rm \
                          ifelse(REDIS_PORT, {{}}, {{}}, -p {{REDIS_PORT}}:6379) \
                          ifelse(DOCKER_VOLUME, {{none}}, {{}}, --volume {{DOCKER_VOLUME}}) \
                          -e "{{REDIS_MAXMEMORY}}=REDIS_MAXMEMORY" \
                          -e "{{REDIS_MAXMEMORY_POLICY}}=REDIS_MAXMEMORY_POLICY" \
                          -e "SERVICE_NAME=DNS_SERVICE_NAME" \
                          -e "SERVICE_ID=DNS_SERVICE_ID" \
                          DOCKER_IMAGE

ExecStop=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStopPost=-/usr/bin/docker rm DOCKER_NAME
TimeoutStopSec=DOCKER_STOP_TIMEOUT{{s}}

RestartSec=15s
Restart=always


[Install]
WantedBy=multi-user.target
