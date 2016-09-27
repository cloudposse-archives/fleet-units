changequote({{,}})dnl
define(DOCKER_NAME, skydns)dnl
define(DOCKER_REGISTRY, index.docker.io)dnl
define(DOCKER_REPOSITORY, skynetservices/skydns)dnl
define(DOCKER_TAG, 2.5.3a)dnl
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
User=root
TimeoutStartSec=0
EnvironmentFile=/etc/environment
EnvironmentFile=/etc/env.d/*
ExecStartPre=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStartPre=-/usr/bin/docker rm DOCKER_NAME
ExecStartPre=-/usr/bin/docker --debug=true pull DOCKER_IMAGE
ExecStartPre=-/usr/bin/etcdctl mk /skydns/config '{"dns_addr":"0.0.0.0:53", "domain": "${LOCAL_DOMAIN}.", "ttl":30}'
ExecStart=/bin/sh -c 'docker run \
                            --name %p \
                            --net=host \
                            -e "SERVICE_NAME=DNS_SERVICE_NAME" \
                            -e "SERVICE_ID=DNS_SERVICE_ID" \
                            -v /run/systemd/resolve/resolv.conf:/etc/resolv.conf \
                            skynetservices/skydns:2.5.3a -nameservers=SKYDNS_NAMESERVERS -machines=http://${COREOS_PRIVATE_IPV4}:4001/ -rcache-ttl SKYDNS_RCACHE_TTL -round-robin SKYDNS_ROUND_ROBIN'

ExecStartPost=/bin/sh -c 'rm -f /etc/resolv.conf \
                          && ( \
                               echo -e "nameserver ${COREOS_PRIVATE_IPV4}\nnameserver 8.8.8.8\nnameserver 8.8.4.4\nsearch ${DOMAIN} ${LOCAL_DOMAIN} svc.${LOCAL_DOMAIN} cluster.${LOCAL_DOMAIN}" | \
                                 sudo tee /etc/resolv.conf \
                             )'

ExecStopPost=/bin/sh -c 'ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf'

Restart=always
RestartSec=10s


[X-Fleet]
Global=true

