changequote({{,}})dnl
define(DB_HOST, )dnl
define(DB_USER, )dnl
define(DB_PASS, )dnl
define(DB_NAME, )dnl
define(IRC_SERV, )dnl
define(IRC_CHAN, )dnl
define(IRC_NICK, )dnl
define(IRC_PASS, )dnl
define(IRC_EMAIL, )dnl
define(SERVICE_PORTS, )dnl
define(SERVICE_LOGS, )dnl
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
Description=IRC BOT (DOCKER_NAME) Service
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
                              ifelse(DB_USER, {{}}, {{}}, -e "{{{{DB_USER}}}}={{DB_USER}}") \
                              ifelse(DB_PASS, {{}}, {{}}, -e "{{{{DB_PASS}}}}={{DB_PASS}}") \
                              ifelse(DB_HOST, {{}}, {{}}, -e "{{{{DB_HOST}}}}={{DB_HOST}}") \
                              ifelse(DB_NAME, {{}}, {{}}, -e "{{{{DB_NAME}}}}={{DB_NAME}}") \
                              ifelse(IRC_SERV, {{}}, {{}}, -e "{{{{IRC_SERV}}}}={{IRC_SERV}}") \
                              ifelse(IRC_NICK, {{}}, {{}}, -e "{{{{IRC_NICK}}}}={{IRC_NICK}}") \
                              ifelse(IRC_CHAN, {{}}, {{}}, -e "{{{{IRC_CHAN}}}}={{IRC_CHAN}}") \
                              ifelse(IRC_PASS, {{}}, {{}}, -e "{{{{IRC_PASS}}}}={{IRC_PASS}}") \
                              ifelse(IRC_EMAIL, {{}}, {{}}, -e "{{{{IRC_EMAIL}}}}={{IRC_EMAIL}}") \
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

