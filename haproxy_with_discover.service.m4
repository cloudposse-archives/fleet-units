changequote({{,}})dnl
define(DOCKER_NAME, {{haproxy}})dnl
define(DOCKER_REGISTRY, {{index.docker.io}})dnl
define(DOCKER_REPOSITORY, {{cloudposse/haproxy-with-discover}})dnl
define(DOCKER_TAG, {{latest}})dnl
define(DOCKER_IMAGE, {{DOCKER_REGISTRY}}/{{DOCKER_REPOSITORY}}:{{DOCKER_TAG}})dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl
define(DOCKER_DNS,)dnl
define(DOCKER_DNS_SEARCH, )dnl
define(DOCKER_MEMORY, 500m)dnl
define(DOCKER_CPU_SHARES, 100)dnl
define(DOCKER_NET,)dnl
define(HAPROXY_PORT, )dnl
define(HAPROXY_ADMIN_PORT, )dnl
define(HAPROXY_BIND_OPTIONS, )dnl
define(HAPROXY_MODE, tcp)dnl
dnl define(HAPROXY_CHECK, )dnl
define(HAPROXY_NAMESERVER, ${COREOS_PRIVATE_IPV4})dnl
define(HAPROXY_CHECK_METHOD, GET)dnl
define(HAPROXY_CHECK_PATH, {{/asdasdad}})dnl
define(HAPROXY_CHECK_VERSION, HTTP/1.1)dnl
define(HAPROXY_CHECK_HOST, {{localhost}})dnl
define(CONFD_PREFIX, /containers/something)dnl
define(DNS_SERVICE_NAME, {{haproxy}})dnl
define(DNS_SERVICE_ID, %H)dnl
define(FLEET_GLOBAL_SERVICE, {{{{true}}}})dnl
   
[Unit]
Description=HAProxy Load Balancer HAPROXY_MODE://ifelse(HAPROXY_PORT, {{}}, {{}}, on port {{HAPROXY_PORT}}) with Discovery watching CONFD_PREFIX for changes 
Requires=docker.service
After=docker.service
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
                          --rm \
                          --name DOCKER_NAME \
                          ifelse(DOCKER_NET, {{}}, {{}}, --net={{DOCKER_NET}}) \
                          ifelse(DOCKER_MEMORY, {{}}, {{}}, --memory={{DOCKER_MEMORY}}) \
                          ifelse(DOCKER_CPU_SHARES, {{}}, {{}}, --cpu-shares={{DOCKER_CPU_SHARES}}) \
                          ifelse(DOCKER_DNS, {{}}, {{}}, --dns={{DOCKER_DNS}}) \
                          ifelse(DOCKER_DNS_SEARCH, {{}}, {{}}, --dns-search={{DOCKER_DNS_SEARCH}}) \
                          ifelse(HAPROXY_PORT, {{}}, {{}}, -p {{HAPROXY_PORT}}:9000) \
                          ifelse(HAPROXY_ADMIN_PORT, {{}}, {{}}, -p {{HAPROXY_ADMIN_PORT}}:9001) \
                          ifelse(HAPROXY_MODE, {{}}, {{}}, -e "{{{{HAPROXY_MODE}}}}={{HAPROXY_MODE}}") \
dnl                          ifelse(HAPROXY_CHECK, {{}}, {{}}, -e "{{{{HAPROXY_CHECK}}}}={{HAPROXY_CHECK}}") \
                          ifelse(HAPROXY_CHECK_METHOD, {{}}, {{}}, -e "{{{{HAPROXY_CHECK_METHOD}}}}={{HAPROXY_CHECK_METHOD}}") \
                          ifelse(HAPROXY_CHECK_PATH, {{}}, {{}}, -e "{{{{HAPROXY_CHECK_PATH}}}}={{HAPROXY_CHECK_PATH}}") \
                          ifelse(HAPROXY_CHECK_VERSION, {{}}, {{}}, -e "{{{{HAPROXY_CHECK_VERSION}}}}={{HAPROXY_CHECK_VERSION}}") \
                          ifelse(HAPROXY_CHECK_HOST, {{}}, {{}}, -e "{{{{HAPROXY_CHECK_HOST}}}}={{HAPROXY_CHECK_HOST}}") \
                          ifelse(HAPROXY_BIND_OPTIONS, {{}}, {{}}, -e "{{{{HAPROXY_BIND_OPTIONS}}}}={{HAPROXY_BIND_OPTIONS}}") \
                          ifelse(HAPROXY_NAMESERVER, {{}}, {{}}, -e "{{{{HAPROXY_NAMESERVER}}}}={{HAPROXY_NAMESERVER}}") \
                          -e "{{CONFD_PREFIX}}=CONFD_PREFIX" \
                          -e "ETCD_HOST=${COREOS_PRIVATE_IPV4}" \
                          -e "SERVICE_9000_NAME=DNS_SERVICE_NAME" \
                          -e "SERVICE_9000_ID=DNS_SERVICE_ID" \
                          DOCKER_IMAGE 
ExecStop=/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStopPost=-/usr/bin/docker rm DOCKER_NAME
TimeoutStopSec=DOCKER_STOP_TIMEOUT{{s}}
RestartSec=5s
Restart=always

[X-Fleet]
Global=FLEET_GLOBAL_SERVICE
