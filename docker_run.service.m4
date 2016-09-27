changequote({{,}})dnl
define(DOCKER_NAME, docker_run)dnl
define(DOCKER_TAG, latest)dnl
define(DOCKER_REGISTRY, index.docker.io)dnl
define(DOCKER_REPOSITORY, )dnl
define(DOCKER_IMAGE, {{DOCKER_REGISTRY}}/{{DOCKER_REPOSITORY}}:{{DOCKER_TAG}})dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl
define(DOCKER_VOLUME, )
define(DOCKER_VOLUME_OCTAL_MODE, 1777)dnl
define(DOCKER_DNS, ${DNS_SERVER})dnl
define(DOCKER_DNS_SEARCH, )dnl
define(DOCKER_RUN_CMD, )
define(FLEET_MACHINE_METADATA, )dnl

[Unit]
Description=Docker Run DOCKER_IMAGE
Requires=docker.service
After=docker.service
Requires=flanneld.service
After=flanneld.service


[Service]
User=core
EnvironmentFile=/etc/environment
EnvironmentFile=/etc/env.d/*
TimeoutStartSec=0
Type=oneshot
RemainAfterExit=no
ExecStartPre=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStartPre=-/usr/bin/docker rm DOCKER_NAME
ExecStartPre=-/usr/bin/docker --debug=true pull DOCKER_IMAGE
ExecStartPre=/usr/bin/sh -c "echo DOCKER_VOLUME | cut -d: -f1 | xargs --no-run-if-empty mkdir -p -m DOCKER_VOLUME_OCTAL_MODE"
ExecStart=/usr/bin/docker run \
                          ifelse(DOCKER_DNS, {{}}, {{}}, --dns={{DOCKER_DNS}}) \
                          ifelse(DOCKER_DNS_SEARCH, {{}}, {{}}, --dns-search={{DOCKER_DNS_SEARCH}}) \
                          --name DOCKER_NAME \
                          --rm \
                          ifelse(DOCKER_VOLUME, {{}}, {{}}, --volume {{DOCKER_VOLUME}}) \
                          DOCKER_IMAGE \
                            DOCKER_RUN_CMD

[Install]
WantedBy=multi-user.target

[X-Fleet]
ifelse(FLEET_MACHINE_METADATA, {{}}, {{}}, {{MachineMetadata=FLEET_MACHINE_METADATA}})

