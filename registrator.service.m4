changequote({{,}})dnl
define(DOCKER_NAME, xregistrator)dnl
define(DOCKER_REGISTRY, index.docker.io)dnl
define(DOCKER_REPOSITORY, {{cloudposse/registrator}})dnl
define(DOCKER_TAG, {{latest}})dnl
define(DOCKER_IMAGE, {{DOCKER_REGISTRY}}/{{DOCKER_REPOSITORY}}:{{DOCKER_TAG}})dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl
define(ETCD_HOST, ${COREOS_PRIVATE_IPV4}:4001)dnl
define(REGISTRATOR_DOMAIN, {{registrator.local}})dnl
define(REGISTRATOR_SCHEMA, skydns2)dnl
define(REGISTRATOR_TTL_DEFAULT, 300)dnl
define(REGISTRATOR_TTL_REFRESH, 120)dnl
define(REGISTRATOR_RESYNC, 60)dnl
define(REGISTRATOR_ARGS, )dnl
define(REGISTRATOR_BIND_TO, )dnl
define(DNS_SERVICE_NAME, {{registrator}})dnl
define(DNS_SERVICE_ID, %H)dnl

[Unit]
Description=Registrator
Requires=docker.service
After=docker.service
Requires={{etcd2.service}}
After={{etcd2.service}}
Requires=flanneld.service
After=flanneld.service
ifelse(REGISTRATOR_BIND_TO, {{}}, {{}}, BindTo={{REGISTRATOR_BIND_TO}})

[Service]
User=core
TimeoutStartSec=0
EnvironmentFile=/etc/environment
EnvironmentFile=/etc/env.d/*
ExecStartPre=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStartPre=-/usr/bin/docker rm DOCKER_NAME
ExecStartPre=-/usr/bin/docker --debug=true pull DOCKER_IMAGE
ExecStart=/usr/bin/docker run \
                          --name DOCKER_NAME \
                          -v /var/run/docker.sock:/tmp/docker.sock \
                          -e "SERVICE_NAME=DNS_SERVICE_NAME" \
                          -e "SERVICE_ID=DNS_SERVICE_ID" \
                          DOCKER_IMAGE \
                          REGISTRATOR_ARGS \
                          -ttl REGISTRATOR_TTL_DEFAULT \
                          -ttl-refresh REGISTRATOR_TTL_REFRESH \
                          REGISTRATOR_SCHEMA://ETCD_HOST/REGISTRATOR_DOMAIN

#                          -resync REGISTRATOR_RESYNC \

ExecStop=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
TimeoutStopSec=DOCKER_STOP_TIMEOUT{{s}}

Restart=always
RestartSec=10s

[X-Fleet]
Global=true
