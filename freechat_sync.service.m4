changequote({{,}})dnl
define(IRC_VHOST, )dnl
define(IRC_DB_HOST, )dnl
define(IRC_DB_USER, )dnl
define(IRC_DB_PASS, )dnl
define(IRC_DB_NAME, )dnl
define(WP_DB_HOST, )dnl
define(WP_DB_USER, )dnl
define(WP_DB_PASS, )dnl
define(WP_DB_NAME, )dnl
define(DOCKER_NAME, )dnl
define(DOCKER_TAG, )dnl
define(DOCKER_REGISTRY, index.docker.io)dnl
define(DOCKER_REPOSITORY, cloudposse/library)dnl
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

[Unit]
Description=DOCKER_NAME Service
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
                              ifelse(IRC_VHOST, {{}}, {{}}, -e "{{{{IRC_VHOST}}}}={{IRC_VHOST}}") \
                              ifelse(IRC_DB_USER, {{}}, {{}}, -e "{{{{IRC_DB_USER}}}}={{IRC_DB_USER}}") \
                              ifelse(IRC_DB_PASS, {{}}, {{}}, -e "{{{{IRC_DB_PASS}}}}={{IRC_DB_PASS}}") \
                              ifelse(IRC_DB_HOST, {{}}, {{}}, -e "{{{{IRC_DB_HOST}}}}={{IRC_DB_HOST}}") \
                              ifelse(IRC_DB_NAME, {{}}, {{}}, -e "{{{{IRC_DB_NAME}}}}={{IRC_DB_NAME}}") \
                              ifelse(WP_DB_USER, {{}}, {{}}, -e "{{{{WP_DB_USER}}}}={{WP_DB_USER}}") \
                              ifelse(WP_DB_PASS, {{}}, {{}}, -e "{{{{WP_DB_PASS}}}}={{WP_DB_PASS}}") \
                              ifelse(WP_DB_HOST, {{}}, {{}}, -e "{{{{WP_DB_HOST}}}}={{WP_DB_HOST}}") \
                              ifelse(WP_DB_NAME, {{}}, {{}}, -e "{{{{WP_DB_NAME}}}}={{WP_DB_NAME}}") \
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

