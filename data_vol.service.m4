changequote({{,}})dnl
define(DOCKER_IMAGE, cloudposse/library:data-vol)dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl
define(DOCKER_NAME, data-vol)dnl
define(DOCKER_VOLUME, /vol:/vol)dnl

[Unit]
Description=Generic Data Volume
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
ExecStartPre=-/usr/bin/docker --debug=true pull DOCKER_IMAGE
# Conditionally create the new data-vol container iff an existing one does not already exist
ExecStart=/bin/sh -c "/usr/bin/docker inspect DOCKER_NAME >/dev/null || /usr/bin/docker create --name DOCKER_NAME --entrypoint=_ -v DOCKER_VOLUME DOCKER_IMAGE"

[Install]
WantedBy=multi-user.target

