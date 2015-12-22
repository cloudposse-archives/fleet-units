changequote({{,}})dnl
define(DOCKER_IMAGE, cloudposse:library/nodejs)dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl
define(DOCKER_NAME, nodejs)dnl
define(NODEJS_PORT, 44444)dnl

[Unit]
Description=NodeJS Server
Requires=docker.service
After=docker.service
Requires=flanneld.service
After=flanneld.service

Requires=NODEJS_DATA_VOL_SERVICE
After=NODEJS_DATA_VOL_SERVICE

[Service]
User=core
EnvironmentFile=/etc/environment
EnvironmentFile=/etc/env.d/*
TimeoutStartSec=0
ExecStartPre=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStartPre=-/usr/bin/docker rm DOCKER_NAME
ExecStartPre=-/usr/bin/docker --debug=true pull DOCKER_IMAGE
ExecStart=/usr/bin/docker run --name DOCKER_NAME -p NODEJS_PORT:44444 DOCKER_IMAGE
ExecStop=/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStopPost=-/usr/bin/docker rm DOCKER_NAME
TimeoutStopSec=DOCKER_STOP_TIMEOUT{{s}}

RestartSec=20s
Restart=always

[Install]
WantedBy=multi-user.target

[X-Fleet]

