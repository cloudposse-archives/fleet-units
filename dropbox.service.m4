changequote({{,}})dnl
define(BIND_MOUNT_SOURCE, )dnl
define(BIND_MOUNT_TARGET, )dnl
define(DOCKER_NAME, )dnl
define(DOCKER_TAG, {{latest}})dnl
define(DOCKER_REGISTRY, index.docker.io)dnl
define(DOCKER_REPOSITORY, {{{{cloudposse/dropbox}}}})dnl
define(DOCKER_IMAGE, {{DOCKER_REGISTRY}}/{{DOCKER_REPOSITORY}}:{{DOCKER_TAG}})dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl
define(DOCKER_VOLUME, )dnl
define(DOCKER_SCRATCH, )dnl
define(DOCKER_DNS, ${DNS_SERVER})dnl
define(DOCKER_DNS_SEARCH, )dnl
define(DOCKER_MEMORY, 500m)dnl
define(DOCKER_CPU_SHARES, 100)dnl
define(DOCKER_BLOCKIO_WEIGHT, 10)dnl
define(DNS_SERVICE_NAME, )dnl
define(DNS_SERVICE_ID, %H)dnl
define(DROPBOX_UID, 1000)dnl
define(DROPBOX_GID, 1000)dnl
define(DROPBOX_EXCLUDE, tmp)dnl
define(FLEET_GLOBAL_SERVICE, {{true}})dnl
define(FLEET_MACHINE_OF, )dnl
define(FLEET_MACHINE_OF_SERVICE, {{FLEET_MACHINE_OF}}.service)dnl
define(FLEET_CONFLICTS_WITH, )dnl
define(FLEET_CONFLICTS_WITH_SERVICE, {{FLEET_CONFLICTS_WITH}}.service)dnl

[Unit]
Description=Dropbox Service
 
[Service]
User=core
EnvironmentFile=/etc/environment
EnvironmentFile=/etc/env.d/*
TimeoutStartSec=0
ExecStartPre=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStartPre=-/usr/bin/docker rm DOCKER_NAME
ExecStartPre=-/usr/bin/docker --debug=true pull DOCKER_IMAGE
ExecStartPre=-/usr/bin/mkdir -p BIND_MOUNT_TARGET BIND_MOUNT_SOURCE
ExecStartPre=-/usr/bin/sudo /usr/bin/umount BIND_MOUNT_TARGET
ExecStartPre=/usr/bin/sudo /usr/bin/mount --bind BIND_MOUNT_SOURCE BIND_MOUNT_TARGET

ExecStart=/usr/bin/docker run --name DOCKER_NAME \
                              --rm \
                              ifelse(DOCKER_MEMORY, {{}}, {{}}, --memory={{DOCKER_MEMORY}}) \
                              ifelse(DOCKER_CPU_SHARES, {{}}, {{}}, --cpu-shares={{DOCKER_CPU_SHARES}}) \
                              ifelse(DOCKER_BLOCKIO_WEIGHT, {{}}, {{}}, --blkio-weight={{DOCKER_BLOCKIO_WEIGHT}}) \
                              ifelse(DOCKER_DNS, {{}}, {{}}, --dns={{DOCKER_DNS}}) \
                              ifelse(DOCKER_DNS_SEARCH, {{}}, {{}}, --dns-search={{DOCKER_DNS_SEARCH}}) \
                              ifelse(DOCKER_VOLUME, {{}}, {{}}, --volume {{DOCKER_VOLUME}}) \
                              ifelse(DOCKER_SCRATCH, {{}}, {{}}, --volume {{DOCKER_SCRATCH}}) \
                              ifelse(DROPBOX_UID, {{}}, {{}}, -e "{{{{DROPBOX_UID}}}}={{DROPBOX_UID}}") \
                              ifelse(DROPBOX_GID, {{}}, {{}}, -e "{{{{DROPBOX_GID}}}}={{DROPBOX_GID}}") \
                              -e "SERVICE_NAME=DNS_SERVICE_NAME" \
                              -e "SERVICE_ID=DNS_SERVICE_ID" \
                              DOCKER_IMAGE \
                                start

ifelse(DROPBOX_EXCLUDE, {{}}, {{}}, ExecStartPost=-/usr/bin/docker exec {{DOCKER_NAME}} /dropboxctl exclude add {{DROPBOX_EXCLUDE}})

ExecStop=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStopPost=-/usr/bin/docker rm DOCKER_NAME
ExecStopPost=/usr/bin/sudo /usr/bin/umount BIND_MOUNT_TARGET
TimeoutStopSec=DOCKER_STOP_TIMEOUT{{s}}

Restart=always
RestartSec=15s


[X-Fleet]
ifelse(FLEET_GLOBAL_SERVICE, {{true}}, {{{{Global=true}}}}, {{}})
ifelse(FLEET_MACHINE_OF_SERVICE, {{.service}}, {{}}, MachineOf={{FLEET_MACHINE_OF_SERVICE}})
ifelse(FLEET_CONFLICTS_WITH_SERVICE, {{.service}}, {{}}, Conflicts={{FLEET_CONFLICTS_WITH_SERVICE}})

