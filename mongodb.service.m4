changequote({{,}})dnl
define(DOCKER_NAME, {{mongodb}})dnl
define(DOCKER_REGISTRY, {{{{index.docker.io}}}})dnl
define(DOCKER_REPOSITORY, {{mongo}})dnl
define(DOCKER_TAG, {{latest}})dnl
define(DOCKER_IMAGE, {{DOCKER_REGISTRY}}/{{DOCKER_REPOSITORY}}:{{DOCKER_TAG}})dnl
define(DOCKER_STOP_TIMEOUT, 120)dnl
define(DOCKER_DNS, ${DNS_SERVER})dnl
define(DOCKER_VOLUME, none)dnl
define(DOCKER_VOLUME_OCTAL_MODE, 1777)dnl
define(DNS_SERVICE_NAME, {{{{mongodb}}}})dnl
define(DNS_SERVICE_ID, {{%H}})dnl

[Unit]
Description=Mongodb Server
{{Requires=docker.service}}
{{After=docker.service}}
Requires=flanneld.service
After=flanneld.service


[Service]
User=core
EnvironmentFile=/etc/environment
EnvironmentFile=/etc/env.d/*
TimeoutStartSec=0
ifelse(DOCKER_VOLUME, {{none}}, {{}}, ExecStartPre=/usr/bin/sh -c "echo {{DOCKER_VOLUME}} | cut -d: -f1 | xargs mkdir -p -m {{DOCKER_VOLUME_OCTAL_MODE}}")
ExecStartPre=-{{/usr/bin/docker}} stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStartPre=-{{/usr/bin/docker}} rm DOCKER_NAME
ExecStartPre=-{{/usr/bin/docker}} --debug=true pull DOCKER_IMAGE
ExecStart={{/usr/bin/docker}} run \
                          --name DOCKER_NAME \
                          ifelse(DOCKER_DNS, {{}}, {{}}, --dns {{DOCKER_DNS}}) \
                          ifelse(DOCKER_VOLUME, {{none}}, {{}}, --volume {{DOCKER_VOLUME}}) \
                          --rm \
                          -e "SERVICE_NAME=DNS_SERVICE_NAME" \
                          -e "SERVICE_ID=DNS_SERVICE_ID" \
                          DOCKER_IMAGE

ExecStop=-{{/usr/bin/docker}} stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStopPost=-{{/usr/bin/docker}} rm DOCKER_NAME
TimeoutStopSec=DOCKER_STOP_TIMEOUT{{s}}

RestartSec=15s
Restart=always


[Install]
WantedBy=multi-user.target
