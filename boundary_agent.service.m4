changequote({{,}})dnl
define(DOCKER_NAME, {{{{boundary-agent}}}})dnl
define(DOCKER_REGISTRY, index.docker.io)dnl
define(DOCKER_TAG, {{{{boundary-agent}}}})dnl
define(DOCKER_REPOSITORY, cloudposse/library:{{DOCKER_TAG}})dnl
define(DOCKER_IMAGE, {{DOCKER_REGISTRY}}/{{DOCKER_REPOSITORY}})dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl
define(DOCKER_MEMORY, 150m)dnl
define(DOCKER_CPU_SHARES, 100)dnl
define(DNS_SERVICE_NAME, {{{{boundary}}}})dnl
define(DNS_SERVICE_ID, {{%H}})dnl
define(BOUNDARY_API_KEY, )dnl
define(BOUNDARY_HOSTNAME, )dnl


[Unit]
Requires=docker.service
After=docker.service
Requires=flanneld.service
After=flanneld.service
Description=Boundary Agent

[Service]
User=core
EnvironmentFile=/etc/environment
EnvironmentFile=/etc/env.d/*
TimeoutStartSec=0
ExecStartPre=-/bin/sh -c "docker inspect DOCKER_NAME >/dev/null && docker rm -f DOCKER_NAME"
ExecStartPre=-/usr/bin/docker --debug=true pull DOCKER_IMAGE
ExecStart=/usr/bin/docker run \
                          --rm \
                          --name DOCKER_NAME \
                          --net=host \
                          ifelse(DOCKER_MEMORY, {{}}, {{}}, --memory={{DOCKER_MEMORY}}) \
                          ifelse(DOCKER_CPU_SHARES, {{}}, {{}}, --cpu-shares={{DOCKER_CPU_SHARES}}) \
                          -e "{{BOUNDARY_API_KEY}}=BOUNDARY_API_KEY" \
                          -e "{{BOUNDARY_HOSTNAME}}=BOUNDARY_HOSTNAME" \
                          DOCKER_IMAGE
ExecStop=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStopPost=-/usr/bin/docker rm DOCKER_NAME
TimeoutStopSec=DOCKER_STOP_TIMEOUT{{s}}
Restart=always
RestartSec=30

[Install]
WantedBy=multi-user.target

[X-Fleet]
Global=true
