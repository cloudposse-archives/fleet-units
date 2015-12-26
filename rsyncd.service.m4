changequote({{,}})dnl
define(DOCKER_NAME, )dnl
define(DOCKER_TAG, {{latest}})dnl
define(DOCKER_REGISTRY, index.docker.io)dnl
define(DOCKER_REPOSITORY, {{cloudposse/rsyncd}})dnl
define(DOCKER_IMAGE, {{DOCKER_REGISTRY}}/{{DOCKER_REPOSITORY}}:{{DOCKER_TAG}})dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl
define(DOCKER_VOLUME, )dnl
define(DOCKER_LOGS, )dnl
define(DOCKER_DNS, ${DNS_SERVER})dnl
define(DOCKER_DNS_SEARCH, )dnl
define(DOCKER_MEMORY, 500m)dnl
define(DOCKER_CPU_SHARES, 100)dnl
define(DNS_SERVICE_NAME, )dnl
define(DNS_SERVICE_ID, %H)dnl
define(SERVICE_PORTS, )dnl
define(SERVICE_LOGS, )dnl
define(RSYNC_UID, )dnl
define(RSYNC_GID, )dnl
define(RSYNC_USERNAME, {{rsync}})dnl
define(RSYNC_PASSWORD, )dnl
define(RSYNC_ALLOW, )dnl
define(RSYNC_VOLUME, /vol)dnl
define(RSYNC_NAME, vol)dnl
define(RSYNC_READ_ONLY, {{false}})dnl
define(RSYNC_TIMEOUT, 300)dnl
define(RSYNC_MAX_CONNECTIONS, 10)dnl
define(FLEET_GLOBAL_SERVICE, {{false}})dnl
define(FLEET_MACHINE_OF, )dnl
define(FLEET_MACHINE_OF_SERVICE, {{FLEET_MACHINE_OF}}.service)dnl
define(FLEET_CONFLICTS_WITH, )dnl
define(FLEET_CONFLICTS_WITH_SERVICE, {{FLEET_CONFLICTS_WITH}}.service)dnl

[Unit]
Description=DOCKER_NAME Service (uid:RSYNC_UID/gid:RSYNC_GID)
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
                              ifelse(RSYNC_UID, {{}}, {{}}, -e "{{{{RSYNC_UID}}}}={{RSYNC_UID}}") \
                              ifelse(RSYNC_GID, {{}}, {{}}, -e "{{{{RSYNC_GID}}}}={{RSYNC_GID}}") \
                              ifelse(RSYNC_USERNAME, {{}}, {{}}, -e "{{{{RSYNC_USERNAME}}}}={{RSYNC_USERNAME}}") \
                              ifelse(RSYNC_PASSWORD, {{}}, {{}}, -e "{{{{RSYNC_PASSWORD}}}}={{RSYNC_PASSWORD}}") \
                              ifelse(RSYNC_ALLOW, {{}}, {{}}, -e "{{{{RSYNC_ALLOW}}}}={{RSYNC_ALLOW}}") \
                              ifelse(RSYNC_VOLUME, {{}}, {{}}, -e "{{{{RSYNC_VOLUME}}}}={{RSYNC_VOLUME}}") \
                              ifelse(RSYNC_NAME, {{}}, {{}}, -e "{{{{RSYNC_NAME}}}}={{RSYNC_NAME}}") \
                              ifelse(RSYNC_READ_ONLY, {{}}, {{}}, -e "{{{{RSYNC_READ_ONLY}}}}={{RSYNC_READ_ONLY}}") \
                              ifelse(RSYNC_TIMEOUT, {{}}, {{}}, -e "{{{{RSYNC_TIMEOUT}}}}={{RSYNC_TIMEOUT}}") \
                              ifelse(RSYNC_MAX_CONNECTIONS, {{}}, {{}}, -e "{{{{RSYNC_MAX_CONNECTIONS}}}}={{RSYNC_MAX_CONNECTIONS}}") \
                              -e "SERVICE_NAME=DNS_SERVICE_NAME" \
                              -e "SERVICE_ID=DNS_SERVICE_ID" \
                              DOCKER_IMAGE

ExecStop=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStopPost=-/usr/bin/docker rm DOCKER_NAME
TimeoutStopSec=DOCKER_STOP_TIMEOUT{{s}}

Restart=always
RestartSec=10s

[Install]
WantedBy=multi-user.target

[X-Fleet]
ifelse(FLEET_GLOBAL_SERVICE, {{true}}, {{{{Global=true}}}}, {{}})
ifelse(FLEET_MACHINE_OF_SERVICE, {{.service}}, {{}}, MachineOf={{FLEET_MACHINE_OF_SERVICE}})
ifelse(FLEET_CONFLICTS_WITH_SERVICE, {{.service}}, {{}}, Conflicts={{FLEET_CONFLICTS_WITH_SERVICE}})

