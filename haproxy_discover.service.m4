changequote({{,}})dnl
define(DOCKER_IMAGE, cloudposse/library:haproxy-discover)dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl
define(DOCKER_NAME, haproxy-discover)dnl
define(HAPROXY_NAME, haproxy)dnl
define(HAPROXY_SERVICE, {{HAPROXY_NAME.service}})dnl
define(BACKEND_NAME, undefined)dnl
define(BACKEND_SERVICE, {{BACKEND_NAME.service}})dnl
define(VOLUMES_FROM, {{HAPROXY_NAME}})dnl

[Unit]
Description=HAProxy Configuration Service
Requires=docker.service
After=docker.service
Requires=flanneld.service
After=flanneld.service


Requires=etcd2.service
After=etcd2.service
BindTo=etcd2.service

# Our data volume must be ready
After=HAPROXY_SERVICE
Requires=HAPROXY_SERVICE
BindTo=HAPROXY_SERVICE

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
# on, the docker socket so it send HUP signals to haproxy, and our data volume
ExecStart=/usr/bin/docker run \
                          --name DOCKER_NAME \
                          -v /var/run/docker.sock:/var/run/docker.sock \
                          --volumes-from=VOLUMES_FROM \
                          -e "ETCD_HOST=${COREOS_PRIVATE_IPV4}" \
                          -e "{{HAPROXY_NAME}}=HAPROXY_NAME" \
                          -e "CONFD_PREFIX=/BACKEND_NAME" \
                          DOCKER_IMAGE

ExecStop=/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStopPost=-/usr/bin/docker rm DOCKER_NAME
TimeoutStopSec=DOCKER_STOP_TIMEOUT{{s}}
Restart=on-failure
TimeoutStartSec=0
TimeoutStopSec=20s
RestartSec=30s

[X-Fleet]
# we need to be on the same machine as btsync.service
MachineOf=HAPROXY_SERVICE
