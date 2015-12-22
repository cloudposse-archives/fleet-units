changequote({{,}})dnl
define(DOCKER_NAME, {{etcd}})dnl
define(DOCKER_REGISTRY, index.docker.io)dnl
define(DOCKER_TAG, {{{{etcd}}}})dnl
define(DOCKER_REPOSITORY, {{cloudposse/library}}:{{DOCKER_TAG}})dnl
define(DOCKER_IMAGE, {{DOCKER_REGISTRY}}/{{DOCKER_REPOSITORY}})dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl
define(DNS_SERVICE_NAME, {{etcd}})dnl
define(DNS_SERVICE_ID, %H)dnl
dnl Discovery token can be generated here: https://discovery.etcd.io/new
define(ETCD_DISCOVERY, https://discovery.etcd.io/SOMETHING)dnl

[Unit]
Description=Private Etcd
Requires=docker.service
After=docker.service
Requires=flanneld.service
After=flanneld.service


[Service]
User=core
EnvironmentFile=/etc/environment
TimeoutStartSec=0
ExecStartPre=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStartPre=-/usr/bin/docker rm DOCKER_NAME
ExecStartPre=-/usr/bin/docker --debug=true pull DOCKER_IMAGE
ExecStart=/usr/bin/docker run \
                          --name DOCKER_NAME \
                          --rm \
                          -e "SERVICE_4001_NAME=DNS_SERVICE_NAME" \
                          -e "SERVICE_4001_ID=DNS_SERVICE_ID" \
                          -e "{{ETCD_DISCOVERY}}=ETCD_DISCOVERY" \
                          DOCKER_IMAGE


ExecStop=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStopPost=-/usr/bin/docker rm DOCKER_NAME
TimeoutStopSec=DOCKER_STOP_TIMEOUT{{s}}

RestartSec=10s
Restart=always

[Install]
WantedBy=multi-user.target

[X-Fleet]
Global=true
