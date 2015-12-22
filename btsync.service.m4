changequote({{,}})dnl
define(DOCKER_NAME, {{{{btsync}}}})dnl
define(DOCKER_REGISTRY, index.docker.io)dnl
define(DOCKER_REPOSITORY, cloudposse/library)dnl
define(DOCKER_TAG, {{{{btsync}}}})dnl
define(DOCKER_IMAGE, {{DOCKER_REGISTRY}}/{{DOCKER_REPOSITORY}}:{{DOCKER_TAG}})dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl
define(DOCKER_DNS, ${DNS_SERVER})dnl
define(DOCKER_VOLUME, /mnt/test:/mnt/test)dnl
define(DOCKER_SCRATCH, /mnt/tmp:/mnt/tmp)dnl
define(DOCKER_VOLUME_OCTAL_MODE, 1777)dnl
define(DOCKER_MEMORY, 50m)dnl
define(DOCKER_CPU_SHARES, 100)dnl
define(DOCKER_CPUSET_CPUS, )dnl
define(DOCKER_BLKIO_WEIGHT, 500)dnl
define(ETCD_HOST, ${COREOS_PRIVATE_IPV4})dnl
define(ETCD_PORT, {{4001}})dnl
define(CONFD_INTERVAL, {{15}})dnl
define(CONFD_PREFIX, {{/}})dnl
define(CONFD_ONETIME, {{false}})dnl
define(BTSYNC_DEBUG, FFFFFFFF)dnl
define(BTSYNC_STORAGE_PATH, {{/btsync}})dnl
define(BTSYNC_SYNC_MAX_TIME_DIFF, {{30}})dnl
define(BTSYNC_MAX_FILE_SIZE_FOR_VERSIONING, {{1}})dnl
define(BTSYNC_FOLDER_RESCAN_INTERVAL, {{600}})dnl
define(BTSYNC_MAX_FILE_SIZE_DIFF_FOR_PATCHING, {{4}})dnl
define(BTSYNC_UID, {{1000}})dnl
define(BTSYNC_GID, {{1000}})dnl
define(BTSYNC_SHARED_SECRET, {{topsecret}})dnl
define(BTSYNC_USE_DHT, {{false}})dnl
define(BTSYNC_USE_TRACKER, {{false}})dnl
define(BTSYNC_SEARCH_LAN, {{false}})dnl
define(BTSYNC_SHARED_DIR, /mnt/test)dnl
define(BTSYNC_KNOWN_HOSTS, \"localhost:44444\")dnl
define(BTSYNC_PORT, 44444)dnl
define(SUPERVISORD_ENABLED, {{true}})dnl
define(DNS_SERVICE_NAME, {{btsync}})dnl
define(DNS_SERVICE_ID, node)dnl
define(FLEET_GLOBAL_SERVICE, true)dnl

{{#}} Generate a new token /usr/bin/docker run -it DOCKER_IMAGE {{/usr/bin/btsync --generate-secret}}


[Unit]
Description=BitTorrent Sync Replication on DOCKER_VOLUME
Requires=docker.service
After=docker.service
Requires=flanneld.service
After=flanneld.service
Requires=systemd-timesyncd.service
After=systemd-timesyncd.service

[Service]
User=core
EnvironmentFile=/etc/environment
EnvironmentFile=/etc/env.d/*
TimeoutStartSec=0
ExecStartPre=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStartPre=-/usr/bin/docker rm DOCKER_NAME
ExecStartPre=-/usr/bin/docker --debug=true pull DOCKER_IMAGE
ExecStartPre=/usr/bin/sh -c "echo DOCKER_SCRATCH | cut -d: -f1 | xargs sudo mkdir -p -m DOCKER_VOLUME_OCTAL_MODE"
ExecStartPre=/usr/bin/sh -c "echo DOCKER_VOLUME | cut -d: -f1 | xargs sudo mkdir -p -m DOCKER_VOLUME_OCTAL_MODE"

ExecStart=/usr/bin/docker run \
                          --dns DOCKER_DNS \
                          --rm \
                          --name DOCKER_NAME \
                          ifelse(DOCKER_MEMORY, {{}}, {{}}, --memory={{DOCKER_MEMORY}}) \
                          ifelse(DOCKER_CPU_SHARES, {{}}, {{}}, --cpu-shares={{DOCKER_CPU_SHARES}}) \
                          ifelse(DOCKER_CPUSET_CPUS, {{}}, {{}}, --cpuset-cpus={{DOCKER_CPUSET_CPUS}}) \
dnl                          ifelse(DOCKER_BLOCKIO_WEIGHT, {{}}, {{}}, --blkio-weight={{DOCKER_BLOCKIO_WEIGHT}}) \
                          -e "{{ETCD_HOST}}=ETCD_HOST" \
                          -e "{{CONFD_INTERVAL}}=CONFD_INTERVAL" \
                          -e "{{CONFD_PREFIX}}=CONFD_PREFIX" \
                          -e "{{CONFD_ONETIME}}=CONFD_ONETIME" \
                          -e "{{BTSYNC_DEBUG}}=BTSYNC_DEBUG" \
                          -e "{{BTSYNC_STORAGE_PATH}}=BTSYNC_STORAGE_PATH" \
                          -e "{{BTSYNC_SYNC_MAX_TIME_DIFF}}=BTSYNC_SYNC_MAX_TIME_DIFF" \
                          -e "{{BTSYNC_MAX_FILE_SIZE_FOR_VERSIONING}}=BTSYNC_MAX_FILE_SIZE_FOR_VERSIONING" \
                          -e "{{BTSYNC_FOLDER_RESCAN_INTERVAL}}=BTSYNC_FOLDER_RESCAN_INTERVAL" \
                          -e "{{BTSYNC_MAX_FILE_SIZE_DIFF_FOR_PATCHING}}=BTSYNC_MAX_FILE_SIZE_DIFF_FOR_PATCHING" \
                          -e "{{BTSYNC_UID}}=BTSYNC_UID" \
                          -e "{{BTSYNC_GID}}=BTSYNC_GID" \
                          -e "{{BTSYNC_SHARED_SECRET}}=BTSYNC_SHARED_SECRET" \
                          -e "{{BTSYNC_USE_DHT}}=BTSYNC_USE_DHT" \
                          -e "{{BTSYNC_USE_TRACKER}}=BTSYNC_USE_TRACKER" \
                          -e "{{BTSYNC_SEARCH_LAN}}=BTSYNC_SEARCH_LAN" \
                          -e "{{BTSYNC_SHARED_DIR}}=BTSYNC_SHARED_DIR" \
                          -e "{{BTSYNC_PORT}}=BTSYNC_PORT" \
                          -e '{{BTSYNC_KNOWN_HOSTS}}=BTSYNC_KNOWN_HOSTS' \
                          -e '{{SUPERVISORD_ENABLED}}=SUPERVISORD_ENABLED' \
                          -e "SERVICE_NAME=DNS_SERVICE_NAME" \
                          -e "SERVICE_ID=DNS_SERVICE_ID" \
                          --volume=DOCKER_SCRATCH  \
                          --volume=DOCKER_VOLUME  \
                          DOCKER_IMAGE 

ExecStop=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStopPost=-/usr/bin/docker rm DOCKER_NAME
TimeoutStopSec=DOCKER_STOP_TIMEOUT{{s}}
RestartSec=25s
Restart=always

[Install]
WantedBy=multi-user.target

[X-Fleet]
Global=FLEET_GLOBAL_SERVICE
