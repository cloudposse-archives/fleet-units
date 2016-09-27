changequote({{,}})dnl
define(REDIS_HOST, )dnl
define(REDIS_PORT, )dnl
define(REDIS_PASSWORD, )dnl
define(REDIS_DATABASE, )dnl
define(SERVICE_PORTS, )dnl
define(SERVICE_LOGS, )dnl
define(DOCKER_NAME, )dnl
define(DOCKER_TAG, latest)dnl
define(DOCKER_REGISTRY, index.docker.io)dnl
define(DOCKER_REPOSITORY, cloudposse/remotecv)dnl
define(DOCKER_IMAGE, {{DOCKER_REGISTRY}}/{{DOCKER_REPOSITORY}}:{{DOCKER_TAG}})dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl
define(DOCKER_VOLUME, )dnl
define(DOCKER_LOGS, )dnl
define(DOCKER_DNS, ${DNS_SERVER})dnl
define(DOCKER_DNS_SEARCH, )dnl
define(DOCKER_MEMORY, 500m)dnl
define(DOCKER_CPU_SHARES, 100)dnl
define(DNS_SERVICE_NAME, )dnl
define(DNS_SERVICE_ID, %H)dnl
define(FLEET_CONFLICTS, %p@*)dnl
define(LOG_LEVEL, )dnl

[Unit]
Description=RemoteCV (DOCKER_NAME) Service
Requires=docker.service
After=docker.service
Requires=flanneld.service
After=flanneld.service

[Service]
User=core
EnvironmentFile=/etc/environment
EnvironmentFile=/etc/env.d/*
TimeoutStartSec=0
ExecStartPre=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStartPre=-/usr/bin/docker rm DOCKER_NAME
ExecStartPre=-/usr/bin/docker --debug=true pull DOCKER_IMAGE
ExecStart=/usr/bin/docker run --name DOCKER_NAME \
                              --rm \
                              ifelse(DOCKER_MEMORY, {{}}, {{}}, --memory={{DOCKER_MEMORY}}) \
                              ifelse(DOCKER_CPU_SHARES, {{}}, {{}}, --cpu-shares={{DOCKER_CPU_SHARES}}) \
                              ifelse(DOCKER_DNS, {{}}, {{}}, --dns={{DOCKER_DNS}}) \
                              ifelse(DOCKER_DNS_SEARCH, {{}}, {{}}, --dns-search={{DOCKER_DNS_SEARCH}}) \
                              ifelse(DOCKER_VOLUME, {{}}, {{}}, --volume {{DOCKER_VOLUME}}) \
                              ifelse(DOCKER_LOGS, {{}}, {{}}, --volume {{DOCKER_LOGS}}) \
                              ifelse(SERVICE_LOGS, {{}}, {{}}, --volume {{SERVICE_LOGS}}) \
                              ifelse(SERVICE_PORTS, {{}}, {{}}, -p {{SERVICE_PORTS}}) \
                              ifelse(REDIS_PORT, {{}}, {{}}, -e "{{{{REDIS_PORT}}}}={{REDIS_PORT}}") \
                              ifelse(REDIS_PASSWORD, {{}}, {{}}, -e "{{{{REDIS_PASSWORD}}}}={{REDIS_PASSWORD}}") \
                              ifelse(REDIS_HOST, {{}}, {{}}, -e "{{{{REDIS_HOST}}}}={{REDIS_HOST}}") \
                              ifelse(REDIS_DATABASE, {{}}, {{}}, -e "{{{{REDIS_DATABASE}}}}={{REDIS_DATABASE}}") \
                              ifelse(LOG_LEVEL, {{}}, {{}}, -e "{{{{LOG_LEVEL}}}}={{LOG_LEVEL}}") \
                              -e "SERVICE_NAME=DNS_SERVICE_NAME" \
                              -e "SERVICE_ID=DNS_SERVICE_ID" \
                              DOCKER_IMAGE

ExecStop=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStopPost=-/usr/bin/docker rm DOCKER_NAME
TimeoutStopSec=DOCKER_STOP_TIMEOUT{{s}}

Restart=always
RestartSec=10s

[Install]
WantedBy=multi-user.target

[X-Fleet]
ifelse(FLEET_CONFLICTS, {{}}, {{}}, Conflicts=FLEET_CONFLICTS)

