changequote({{,}})dnl
define(DOCKER_IMAGE, cloudposse/library:data-vol)dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl
define(DOCKER_NAME, data-vol)dnl
define(DOCKER_VOLUME, /vol)dnl

[Unit]
Description=Generic Ephemeral Data Volume
Requires=docker.service
After=docker.service
Requires=flanneld.service
After=flanneld.service


[Service]
User=core
Type=oneshot
RemainAfterExit=yes
EnvironmentFile=/etc/environment
EnvironmentFile=/etc/env.d/*
TimeoutStartSec=0
ExecStartPre=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStartPre=-/usr/bin/docker rm DOCKER_NAME
ExecStartPre=-/usr/bin/docker --debug=true pull DOCKER_IMAGE
ExecStart=/usr/bin/docker create --name DOCKER_NAME --entrypoint=_ -v DOCKER_VOLUME DOCKER_IMAGE
ExecStop=/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStopPost=-/usr/bin/docker rm DOCKER_NAME
TimeoutStopSec=DOCKER_STOP_TIMEOUT{{s}}


[Install]
WantedBy=multi-user.target

