changequote({{,}})dnl
define(DOCKER_NAME, skydns)dnl
define(DOCKER_REGISTRY, index.docker.io)dnl
define(DOCKER_REPOSITORY, skynetservices/skydns)dnl
define(DOCKER_TAG, 2.3.0a)dnl
define(DOCKER_IMAGE, {{DOCKER_REPOSITORY}}:{{DOCKER_TAG}})dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl
define(ETCD_HOST, ${COREOS_PRIVATE_IPV4}:4001)dnl
define(DNS_SERVICE_NAME, skydns)dnl
define(DNS_SERVICE_ID, %H)dnl

[Unit]
Description=Test Service
Requires=docker.service
After=docker.service
Requires=fleet.service
After=fleet.service
Requires=flanneld.service
After=flanneld.service


[Service]
Type=oneshot
TimeoutStartSec=0
EnvironmentFile=/etc/environment
EnvironmentFile=/etc/env.d/*
ExecStartPre=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStartPre=-/usr/bin/docker rm DOCKER_NAME
ExecStartPre=-/usr/bin/docker --debug=true pull DOCKER_IMAGE
ExecStart=/bin/sh -c 'echo -n DNS_SERVER=; ifconfig docker0|grep netmask |awk "{print \$2}" > /tmp/test.txt'



