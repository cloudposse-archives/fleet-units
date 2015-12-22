changequote({{,}})dnl
define(DOCKER_NAME, )dnl
define(DOCKER_TAG, {{rsync}})dnl
define(DOCKER_REGISTRY, index.docker.io)dnl
define(DOCKER_REPOSITORY, cloudposse/library)dnl
define(DOCKER_IMAGE, {{DOCKER_REGISTRY}}/{{DOCKER_REPOSITORY}}:{{DOCKER_TAG}})dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl
define(DOCKER_VOLUME, )dnl
define(DOCKER_VOLUME_OCTAL_MODE, 1777)dnl
define(DOCKER_LOGS, )dnl
define(DOCKER_DNS, ${DNS_SERVER})dnl
define(DOCKER_DNS_SEARCH, )dnl
define(DOCKER_MEMORY, 500m)dnl
define(DOCKER_CPU_SHARES, 100)dnl
define(DNS_SERVICE_NAME, )dnl
define(DNS_SERVICE_ID, %H)dnl
define(SERVICE_PORTS, )dnl
define(SERVICE_LOGS, )dnl
define(RSYNC_PASSWORD, )dnl
define(RSYNC_ARGS, )dnl
define(RSYNC_SOURCE, )dnl
define(RSYNC_DESTINATION, )dnl
define(RSYNC_VOLUME, {{RSYNC_SOURCE}})dnl
define(RSYNC_INTERVAL, on-exit)dnl
define(FLEET_MACHINE_OF, )dnl
define(FLEET_MACHINE_OF_SERVICE, {{FLEET_MACHINE_OF}}.service)dnl
define(FLEET_CONFLICTS_WITH, )dnl
define(FLEET_CONFLICTS_WITH_SERVICE, {{FLEET_CONFLICTS_WITH}}.service)dnl
define(FLEET_GLOBAL_SERVICE, {{{{false}}}})dnl


[Unit]
Description=DOCKER_NAME Service
Requires=docker.service
After=docker.service
Requires=flanneld.service
After=flanneld.service

[Service]
User=core
EnvironmentFile=/etc/environment
EnvironmentFile=/etc/env.d/*
TimeoutStartSec=0
ifelse(DOCKER_VOLUME, {{none}}, {{}}, ExecStartPre=/usr/bin/sh -c "echo {{DOCKER_VOLUME}} | cut -d: -f1 | xargs mkdir -p -m DOCKER_VOLUME_OCTAL_MODE")
ExecStartPre=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStartPre=-/usr/bin/docker rm DOCKER_NAME
ExecStartPre=-/usr/bin/docker --debug=true pull DOCKER_IMAGE
dnl Sync from SOURCE <= DESTINATION (restore)
ExecStartPre=-/usr/bin/docker run --name DOCKER_NAME \
                              --rm \
                              ifelse(DOCKER_DNS, {{}}, {{}}, --dns={{DOCKER_DNS}}) \
                              ifelse(DOCKER_DNS_SEARCH, {{}}, {{}}, --dns-search={{DOCKER_DNS_SEARCH}}) \
                              ifelse(DOCKER_VOLUME, {{}}, {{}}, --volume {{DOCKER_VOLUME}}) \
                              ifelse(RSYNC_PASSWORD, {{}}, {{}}, -e "{{{{RSYNC_PASSWORD}}}}={{RSYNC_PASSWORD}}") \
                              ifelse(RSYNC_VOLUME, {{}}, {{}}, -e "{{{{RSYNC_VOLUME}}}}={{RSYNC_VOLUME}}") \
                              DOCKER_IMAGE \
                                RSYNC_ARGS \
                                RSYNC_DESTINATION \
                                RSYNC_SOURCE 

dnl By default just sleep for infinity and don't do any regular backups
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
                              ifelse(RSYNC_PASSWORD, {{}}, {{}}, -e "{{{{RSYNC_PASSWORD}}}}={{RSYNC_PASSWORD}}") \
                              ifelse(RSYNC_VOLUME, {{}}, {{}}, -e "{{{{RSYNC_VOLUME}}}}={{RSYNC_VOLUME}}") \
                              ifelse(RSYNC_INTERVAL, {{}}, {{}}, -e "{{{{RSYNC_INTERVAL}}}}={{RSYNC_INTERVAL}}") \
                              -e "SERVICE_NAME=DNS_SERVICE_NAME" \
                              -e "SERVICE_ID=DNS_SERVICE_ID" \
                              DOCKER_IMAGE \
                                RSYNC_ARGS \
                                RSYNC_SOURCE \
                                RSYNC_DESTINATION

ExecStop=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStopPost=-/usr/bin/docker rm DOCKER_NAME

TimeoutStopSec=DOCKER_STOP_TIMEOUT{{s}}

dnl Restart=always
dnl RestartSec=10s

[Install]
WantedBy=multi-user.target

[X-Fleet]
ifelse(FLEET_MACHINE_OF_SERVICE, {{.service}}, {{}}, MachineOf={{FLEET_MACHINE_OF_SERVICE}})
ifelse(FLEET_CONFLICTS_WITH_SERVICE, {{.service}}, {{}}, Conflicts={{FLEET_CONFLICTS_WITH_SERVICE}})
ifelse(FLEET_GLOBAL_SERVICE, {{true}}, {{Global=FLEET_GLOBAL_SERVICE}}, {{}})
