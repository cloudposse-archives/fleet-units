changequote({{,}})dnl
define(DOCKER_NAME, postfix)dnl
define(DOCKER_REGISTRY, index.docker.io)dnl
define(DOCKER_TAG, latest)dnl
dnl define(DOCKER_REPOSITORY, onesysadmin/ubuntu-postfix:DOCKER_TAG)dnl
define(DOCKER_REPOSITORY, cloudposse/postfix:DOCKER_TAG)dnl
define(DOCKER_IMAGE, DOCKER_REGISTRY/DOCKER_REPOSITORY)dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl
define(DOCKER_DNS, ${DNS_SERVER})dnl
define(DOCKER_HOSTNAME, something.smtp.ourcloud.local)dnl
define(POSTFIX_PORT, )dnl
define(DNS_SERVICE_NAME, postfix)dnl
define(DNS_SERVICE_ID, %H)dnl

[Unit]
Description=Postfix SMTP on DOCKER_HOSTNAME
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
ExecStart=/usr/bin/docker run \
                          --name DOCKER_NAME \
                          --rm \
                          --log-driver=syslog \
dnl                          --volume /dev/log:/dev/log \
                          ifelse(DOCKER_DNS, {{}}, {{}}, --dns {{DOCKER_DNS}}) \
                          ifelse(DOCKER_HOSTNAME, {{none}}, {{}}, --hostname {{DOCKER_HOSTNAME}}) \
                          ifelse(POSTFIX_PORT, {{}}, {{}}, -p {{POSTFIX_PORT}}:25) \
                          -e "SERVICE_25_NAME=DNS_SERVICE_NAME" \
                          -e "SERVICE_25_ID=DNS_SERVICE_ID" \
                          DOCKER_IMAGE --mail-name DOCKER_HOSTNAME --trust-local --trust-rfc1918

ExecStop=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStopPost=-/usr/bin/docker rm DOCKER_NAME

TimeoutStopSec=DOCKER_STOP_TIMEOUT{{s}}

RestartSec=10s
Restart=always

[Install]
WantedBy=multi-user.target
