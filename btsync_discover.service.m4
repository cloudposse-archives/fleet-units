changequote({{,}})dnl
define(DOCKER_NAME, btsync-discover)dnl
define(DOCKER_MEMORY, 50m)dnl
define(DOCKER_CPU_SHARES, 100)dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl
define(BTSYNC_NAME, btsync)dnl
define(BTSYNC_SERVICE, {{BTSYNC_NAME}}.service)dnl
define(VOLUMES_FROM, {{BTSYNC_NAME}})dnl
define(DOCKER_IMAGE, cloudposse/btsync-discover:latest)dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl

[Unit]
Description=BitTorrent Sync Configuration Service

Requires=docker.service
After=docker.service
Requires=flanneld.service
After=flanneld.service

Requires=etcd2.service
After=etcd2.service
BindTo=etcd2.service

# Our data volume must be ready
After=BTSYNC_SERVICE
Requires=BTSYNC_SERVICE
BindTo=BTSYNC_SERVICE

[Service]
User=core
EnvironmentFile=/etc/environment
EnvironmentFile=/etc/env.d/*

# Kill any existing discovery service
ExecStartPre=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStartPre=-/usr/bin/docker rm DOCKER_NAME

# preload container...this ensures we fail if our registry is down and we can't
# obtain the build we're expecting
ExecStartPre=-/usr/bin/docker --debug=true pull DOCKER_IMAGE

# We need to provide our confd container with the IP it can reach etcd
# on, the docker socket so it send HUP signals to nginx, and our data volume
ExecStart=/usr/bin/docker run \
                          --rm \
                          -e "ETCD_HOST=${COREOS_PRIVATE_IPV4}" \
                          -v "/var/run/docker.sock:/var/run/docker.sock" \
                          --volumes-from=VOLUMES_FROM \
                          --name DOCKER_NAME \
                          ifelse(DOCKER_MEMORY, {{}}, {{}}, --memory={{DOCKER_MEMORY}}) \
                          ifelse(DOCKER_CPU_SHARES, {{}}, {{}}, --cpu-shares={{DOCKER_CPU_SHARES}}) \
                          DOCKER_IMAGE

ExecStop=/usr/bin/docker stop --time DOCKER_STOP_TIMEOUT DOCKER_NAME
Restart=on-failure
TimeoutStartSec=0
TimeoutStopSec=DOCKER_STOP_TIMEOUT{{s}}
RestartSec=30s

[X-Fleet]
# we need to be on the same machine as btsync.service
MachineOf=BTSYNC_SERVICE
