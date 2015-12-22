changequote({{,}})dnl
define(DOCKER_NAME, {{os_fw}})dnl
define(DOCKER_REGISTRY, index.docker.io)dnl
define(DOCKER_TAG, core-fw)dnl
define(DOCKER_REPOSITORY, {{{{cloudposse/library}}}}:DOCKER_TAG)dnl
define(DOCKER_IMAGE, DOCKER_REGISTRY/{{DOCKER_REPOSITORY}})dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl
define(ETCD_DISCOVERY_URL, ${ETCD_DISCOVERY})dnl
define(ENV_NAME, )dnl
define(ENV_SERVICE, {{ENV_NAME}}.service)dnl


[Unit]
Description=CoreOS Firewall
Requires=docker.socket
After=docker.socket
Before=flanneld.service
ifelse(ENV_SERVICE, {{.service}}, {{}}, Requires={{ENV_SERVICE}})
ifelse(ENV_SERVICE, {{.service}}, {{}}, After={{ENV_SERVICE}})

[Service]
User=core
Type=oneshot
RemainAfterExit=no
EnvironmentFile=/etc/environment
EnvironmentFile=/etc/env.d/*

TimeoutStartSec=0
ExecStartPre=-/usr/bin/docker rm DOCKER_NAME
ExecStartPre=-/usr/bin/docker --debug=true pull DOCKER_IMAGE
ExecStartPre=/usr/bin/echo "Discovery URL: ETCD_DISCOVERY_URL"
ExecStart=/usr/bin/docker run \
                          --rm \
                          --privileged \
                          --net=host \
                          --name DOCKER_NAME \
                          DOCKER_IMAGE up ETCD_DISCOVERY_URL

[Install]
WantedBy=multi-user.target

[X-Fleet]
Global=true

