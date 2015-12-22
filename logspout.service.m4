changequote({{,}})dnl
define(DOCKER_IMAGE, progrium/logspout:latest)dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl
define(DOCKER_NAME, logspout)dnl
define(DOCKER_SERVICE, {{DOCKER_NAME.service}})dnl
define(LOGSPOUT_SYSLOG_ENDPOINT, syslog://logs2.papertrailapp.com:123456)dnl

[Unit]
Description=Logspout service
Requires=docker.service
After=docker.service
Requires=flanneld.service
After=flanneld.service


[Service]
EnvironmentFile=/etc/environment
EnvironmentFile=/etc/env.d/*
TimeoutStartSec=0
KillMode=none

ExecStartPre=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStartPre=-/usr/bin/docker rm DOCKER_NAME
ExecStartPre=-/usr/bin/docker --debug=true pull DOCKER_IMAGE
ExecStart=/usr/bin/docker run --name DOCKER_NAME -v=/var/run/docker.sock:/tmp/docker.sock DOCKER_IMAGE -h "%H" LOGSPOUT_SYSLOG_ENDPOINT

ExecStop=/usr/bin/docker stop DOCKER_NAME
TimeoutStopSec=DOCKER_STOP_TIMEOUT{{s}}

Restart=on-failure
TimeoutSec=300
RestartSec=1

[X-Fleet]
Global=true
