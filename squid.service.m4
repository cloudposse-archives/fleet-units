changequote({{,}})dnl
define(SQUID_USERNAME, )dnl
define(SQUID_PASSWORD, )dnl
define(SQUID_LOCALNET, 127.0.0.1/32)dnl
define(SQUID_CACHE_PEER, )dnl
define(SQUID_NEVER_DIRECT, )dnl
define(DOCKER_NAME, squid)dnl
define(DOCKER_REGISTRY, index.docker.io)dnl
define(DOCKER_REPOSITORY, {{{{cloudposse}}}}/{{squid}})dnl
define(DOCKER_TAG,latest)dnl
define(DOCKER_IMAGE, {{DOCKER_REGISTRY}}/{{DOCKER_REPOSITORY}}:{{DOCKER_TAG}})dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl
define(DOCKER_VOLUME, )dnl
define(DOCKER_DNS, ${DNS_SERVER})dnl
define(DOCKER_DNS_SEARCH, )dnl
define(DOCKER_MEMORY, 500m)dnl
define(DOCKER_CPU_SHARES, 100)dnl
define(DNS_SERVICE_NAME, squid)dnl
define(DNS_SERVICE_ID, %H)dnl
define(FLEET_CONFLICTS, %p@*)dnl


[Unit]
Description=Squid Proxy Server
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
                              ifelse(SQUID_USERNAME, {{}}, {{}}, -e "{{{{SQUID_USERNAME}}}}={{SQUID_USERNAME}}") \
                              ifelse(SQUID_PASSWORD, {{}}, {{}}, -e "{{{{SQUID_PASSWORD}}}}={{SQUID_PASSWORD}}") \
                              ifelse(SQUID_LOCALNET, {{}}, {{}}, -e "{{{{SQUID_LOCALNET}}}}={{SQUID_LOCALNET}}") \
                              ifelse(SQUID_CACHE_PEER, {{}}, {{}}, -e "{{{{SQUID_CACHE_PEER}}}}={{SQUID_CACHE_PEER}}") \
                              ifelse(SQUID_NEVER_DIRECT, {{}}, {{}}, -e "{{{{SQUID_NEVER_DIRECT}}}}={{SQUID_NEVER_DIRECT}}") \
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

