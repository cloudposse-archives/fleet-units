changequote({{,}})dnl
define(DOCKER_NAME, skydns)dnl
define(DOCKER_REGISTRY, index.docker.io)dnl
define(DOCKER_REPOSITORY, skynetservices/skydns)dnl
define(DOCKER_TAG, 2.3.0a)dnl
define(DOCKER_IMAGE, {{DOCKER_REPOSITORY}}:{{DOCKER_TAG}})dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl
define(ETCD_HOST, ${COREOS_PRIVATE_IPV4}:4001)dnl
define(SKYDNS_PORT, 53)dnl
define(SKYDNS_DOMAIN, skydns.local)dnl
define(SKYDNS_NAMESERVERS, {{8.8.8.8:53,8.8.4.4:53}})dnl
define(SKYDNS_TTL, 300)dnl
define(SKYDNS_RCACHE_TTL, 60)dnl
define(SKYDNS_ROUND_ROBIN, {{{{true}}}})dnl
define(DNS_SERVICE_NAME, skydns)dnl
define(DNS_SERVICE_ID, %H)dnl

[Unit]
Description=SkyDNS
Requires=docker.service
After=docker.service
Requires=fleet.service
After=fleet.service
Requires=flanneld.service
After=flanneld.service


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
                          -p SKYDNS_PORT:53/udp \
                          -e "{{SKYDNS_DOMAIN}}=SKYDNS_DOMAIN" \
                          -e "{{SKYDNS_NAMESERVERS}}=SKYDNS_NAMESERVERS" \
                          -e "{{ETCD_MACHINES}}=ETCD_HOST" \
                          -e "SERVICE_NAME=DNS_SERVICE_NAME" \
                          -e "SERVICE_ID=DNS_SERVICE_ID" \
                          DOCKER_IMAGE \
                          -discover \
                          -addr 0.0.0.0:53 \
                          -rcache-ttl SKYDNS_RCACHE_TTL \
                          -round-robin SKYDNS_ROUND_ROBIN 

#ExecStartPost=/bin/sh -c "ip=($(ifconfig docker0| grep netmask)); echo DNS_SERVER=\${ip[1]}| sudo tee /etc/env.d/dns.sh"
ExecStartPost=/bin/sh -c "ip route |grep docker0|xargs -n1 echo |tail -1|xargs -I: echo DNS_SERVER=:|sudo tee /etc/env.d/dns.sh"

Restart=always
RestartSec=10s


[X-Fleet]
Global=true

