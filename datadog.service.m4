changequote({{,}})dnl
define(DOCKER_NAME, {{datadog}})dnl
define(DOCKER_REGISTRY, index.docker.io)dnl
define(DOCKER_TAG, latest)dnl
define(DOCKER_REPOSITORY, {{{{datadog/docker-dd-agent}}}}:DOCKER_TAG)dnl
define(DOCKER_IMAGE, DOCKER_REGISTRY/{{DOCKER_REPOSITORY}})dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl
define(DOCKER_HOSTNAME, {{%H}})dnl
define(DOCKER_MEMORY, 100m)dnl
define(DOCKER_CPU_SHARES, 100)dnl
define(DNS_SERVICE_NAME, {{datadog}})dnl
define(DNS_SERVICE_ID, %H)dnl
define(DATADOG_API_KEY, )dnl

[Unit]
Description=Datadog Agent
Requires=docker.socket
After=docker.socket
Requires=flanneld.service
After=flanneld.service

[Service]
User=core
EnvironmentFile=/etc/environment
EnvironmentFile=/etc/env.d/*
TimeoutStartSec=0
ExecStartPre=-/bin/sh -c "docker inspect DOCKER_NAME >/dev/null && docker rm -f DOCKER_NAME"
ExecStartPre=-/usr/bin/docker --debug=true pull DOCKER_IMAGE

ExecStart=/usr/bin/docker run \
                          --rm \
                          --privileged \
                          --name DOCKER_NAME \
                          --hostname DOCKER_HOSTNAME \
                          ifelse(DOCKER_MEMORY, {{}}, {{}}, --memory={{DOCKER_MEMORY}}) \
                          ifelse(DOCKER_CPU_SHARES, {{}}, {{}}, --cpu-shares={{DOCKER_CPU_SHARES}}) \
                          -v /var/run/docker.sock:/var/run/docker.sock \
                          -v /proc/mounts:/host/proc/mounts:ro \
                          -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro \
                          -e "API_KEY=DATADOG_API_KEY" \
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

