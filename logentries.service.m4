changequote({{,}})dnl
define(DOCKER_NAME, apache)dnl
define(DOCKER_REGISTRY, quay.io)dnl
define(DOCKER_REPOSITORY, {{DOCKER_REGISTRY}}/{{{{kelseyhightower/journal-2-logentries}}}})dnl
define(DOCKER_TAG, latest)dnl
define(DOCKER_IMAGE, {{DOCKER_REPOSITORY}}:{{DOCKER_TAG}})dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl
define(DOCKER_DNS, ${DNS_SERVER})dnl
define(DOCKER_DNS_SEARCH, )dnl
define(DNS_SERVICE_NAME, logentries)dnl
define(DNS_SERVICE_ID, %H)dnl
define(LOGENTRIES_TOKEN, )dnl

[Unit]
Description=Forward Systemd Journal to logentries.com
Requires=docker.service
After=docker.service
Requires=flanneld.service
After=flanneld.service


[Service]
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
                          -e "SERVICE_NAME=DNS_SERVICE_NAME" \
                          -e "SERVICE_ID=DNS_SERVICE_ID" \
                          -e "{{LOGENTRIES_TOKEN}}=LOGENTRIES_TOKEN" \
                          -v /run/journald.sock:/run/journald.sock \
                          DOCKER_IMAGE

ExecStop=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStopPost=-/usr/bin/docker rm DOCKER_NAME
TimeoutStopSec=DOCKER_STOP_TIMEOUT{{s}}

Restart=always
RestartSec=10s


[X-Fleet]
Global=true
