changequote({{,}})dnl
define(VARNISH_PORT, )dnl
define(VARNISH_CANONICAL_HOST, )dnl
define(VARNISH_BACKEND_HOST, {{localhost}})dnl
define(VARNISH_BACKEND_PORT, {{80}})dnl
define(VARNISH_BACKEND_FIRST_BYTE_TIMEOUT, {{600s}})dnl
define(VARNISH_BACKEND_CONNECT_TIMEOUT, {{5s}})dnl
define(VARNISH_BACKEND_BETWEEN_BYTES_TIMEOUT, {{20s}})dnl
define(VARNISH_PROBE_REQUEST, GET /wp-login/ HTTP/1.1)dnl
define(VARNISH_PROBE_HOST, localhost)dnl
define(VARNISH_PROBE_WINDOW, 5)dnl
define(VARNISH_PROBE_THRESHOLD, 3)dnl
define(VARNISH_PROBE_INTERVAL, 5s)dnl
define(VARNISH_PROBE_TIMEOUT, 15000ms)dnl
{{#}} Health grace must be greater than VARNISH_PROBE_INTERVAL * VARNISH_PROBE_THRESHOLD + VARNISH_TTL_CONTENT
define(VARNISH_GRACE_HEALTHY, 600s)dnl
define(VARNISH_GRACE_UNHEALTHY, 48h)dnl
define(VARNISH_TTL_CONTENT, 300s)dnl
define(VARNISH_TTL_ASSETS, 1d)dnl

define(VARNISH_CONFIG_TEMPLATE, default.vcl.m4)dnl
define(VARNISH_STORAGE, 1G)dnl
define(VARNISH_THREAD_POOLS, 25)dnl
define(VARNISH_THREAD_POOL_MIN, 100)dnl
define(VARNISH_CLI_TIMEOUT, 86400)dnl
define(VARNISH_SESS_TIMEOUT, 30)dnl

define(CONFD_PREFIX, /containers/something)dnl

define(DOCKER_NAME, varnish)dnl
define(DOCKER_REGISTRY, index.docker.io)dnl
define(DOCKER_REPOSITORY, cloudposse/varnish)dnl
define(DOCKER_TAG, {{latest}})dnl
define(DOCKER_IMAGE, {{DOCKER_REGISTRY}}/{{DOCKER_REPOSITORY}}:{{DOCKER_TAG}})dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl
define(DOCKER_VOLUME, )dnl
define(DOCKER_LOGS, )dnl
define(DOCKER_DNS, ${DNS_SERVER})dnl
define(DOCKER_DNS_SEARCH, )dnl
define(DOCKER_MEMORY, 500m)dnl
define(DOCKER_CPU_SHARES, 100)dnl
define(DNS_SERVICE_NAME, varnish)dnl
define(DNS_SERVICE_ID, %H)dnl
define(FLEET_CONFLICTS, %p@*)dnl


[Unit]
Description=Varnish Cache Server
Requires=docker.service
After=docker.service
Requires=flanneld.service
After=flanneld.service

[Service]
User=core
EnvironmentFile=/etc/environment
EnvironmentFile=/etc/env.d/*
TimeoutStartSec=0
ExecStartPre=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStartPre=-/usr/bin/docker rm DOCKER_NAME
ExecStartPre=-/usr/bin/docker --debug=true pull DOCKER_IMAGE
ExecStart=/usr/bin/docker run --name DOCKER_NAME \
  --rm \
  -e "SERVICE_80_NAME=DNS_SERVICE_NAME" \
  -e "SERVICE_80_ID=DNS_SERVICE_ID" \
  ifelse(DOCKER_MEMORY, {{}}, {{}}, --memory={{DOCKER_MEMORY}}) \
  ifelse(DOCKER_CPU_SHARES, {{}}, {{}}, --cpu-shares={{DOCKER_CPU_SHARES}}) \
  ifelse(DOCKER_DNS, {{}}, {{}}, --dns={{DOCKER_DNS}}) \
  ifelse(DOCKER_DNS_SEARCH, {{}}, {{}}, --dns-search={{DOCKER_DNS_SEARCH}}) \
  ifelse(DOCKER_VOLUME, {{}}, {{}}, --volume {{DOCKER_VOLUME}}) \
  ifelse(DOCKER_LOGS, {{}}, {{}}, --volume {{DOCKER_LOGS}}) \
  ifelse(VARNISH_PORT, {{}}, {{}}, -p {{VARNISH_PORT}}:80) \
  ifelse(DOCKER_NAME, {{}}, {{}}, -e "{{{{VARNISH_NAME}}}}={{DOCKER_NAME}}") \
  ifelse(VARNISH_CANONICAL_HOST, {{}}, {{}}, -e "{{{{VARNISH_CANONICAL_HOST}}}}={{VARNISH_CANONICAL_HOST}}") \
  ifelse(VARNISH_BACKEND_HOST, {{}}, {{}}, -e "{{{{VARNISH_BACKEND_HOST}}}}={{VARNISH_BACKEND_HOST}}") \
  ifelse(VARNISH_BACKEND_PORT, {{}}, {{}}, -e "{{{{VARNISH_BACKEND_PORT}}}}={{VARNISH_BACKEND_PORT}}") \
  ifelse(VARNISH_BACKEND_FIRST_BYTE_TIMEOUT, {{}}, {{}}, -e "{{{{VARNISH_BACKEND_FIRST_BYTE_TIMEOUT}}}}={{VARNISH_BACKEND_FIRST_BYTE_TIMEOUT}}") \
  ifelse(VARNISH_BACKEND_CONNECT_TIMEOUT, {{}}, {{}}, -e "{{{{VARNISH_BACKEND_CONNECT_TIMEOUT}}}}={{VARNISH_BACKEND_CONNECT_TIMEOUT}}") \
  ifelse(VARNISH_BACKEND_BETWEEN_BYTES_TIMEOUT, {{}}, {{}}, -e "{{{{VARNISH_BACKEND_BETWEEN_BYTES_TIMEOUT}}}}={{VARNISH_BACKEND_BETWEEN_BYTES_TIMEOUT}}") \
  ifelse(VARNISH_PROBE_REQUEST, {{}}, {{}}, -e "{{{{VARNISH_PROBE_REQUEST}}}}={{VARNISH_PROBE_REQUEST}}") \
  ifelse(VARNISH_PROBE_HOST, {{}}, {{}}, -e "{{{{VARNISH_PROBE_HOST}}}}={{VARNISH_PROBE_HOST}}") \
  ifelse(VARNISH_PROBE_WINDOW, {{}}, {{}}, -e "{{{{VARNISH_PROBE_WINDOW}}}}={{VARNISH_PROBE_WINDOW}}") \
  ifelse(VARNISH_PROBE_THRESHOLD, {{}}, {{}}, -e "{{{{VARNISH_PROBE_THRESHOLD}}}}={{VARNISH_PROBE_THRESHOLD}}") \
  ifelse(VARNISH_PROBE_INTERVAL, {{}}, {{}}, -e "{{{{VARNISH_PROBE_INTERVAL}}}}={{VARNISH_PROBE_INTERVAL}}") \
  ifelse(VARNISH_PROBE_TIMEOUT, {{}}, {{}}, -e "{{{{VARNISH_PROBE_TIMEOUT}}}}={{VARNISH_PROBE_TIMEOUT}}") \
  ifelse(VARNISH_GRACE_HEALTHY, {{}}, {{}}, -e "{{{{VARNISH_GRACE_HEALTHY}}}}={{VARNISH_GRACE_HEALTHY}}") \
  ifelse(VARNISH_GRACE_UNHEALTHY, {{}}, {{}}, -e "{{{{VARNISH_GRACE_UNHEALTHY}}}}={{VARNISH_GRACE_UNHEALTHY}}") \
  ifelse(VARNISH_TTL_CONTENT, {{}}, {{}}, -e "{{{{VARNISH_TTL_CONTENT}}}}={{VARNISH_TTL_CONTENT}}") \
  ifelse(VARNISH_TTL_ASSETS, {{}}, {{}}, -e "{{{{VARNISH_TTL_ASSETS}}}}={{VARNISH_TTL_ASSETS}}") \
  ifelse(VARNISH_CONFIG_TEMPLATE, {{}}, {{}}, -e "{{{{VARNISH_CONFIG_TEMPLATE}}}}={{VARNISH_CONFIG_TEMPLATE}}") \
  ifelse(VARNISH_STORAGE, {{}}, {{}}, -e "{{{{VARNISH_STORAGE}}}}={{VARNISH_STORAGE}}") \
  ifelse(VARNISH_THREAD_POOLS, {{}}, {{}}, -e "{{{{VARNISH_THREAD_POOLS}}}}={{VARNISH_THREAD_POOLS}}") \
  ifelse(VARNISH_THREAD_POOL_MIN, {{}}, {{}}, -e "{{{{VARNISH_THREAD_POOL_MIN}}}}={{VARNISH_THREAD_POOL_MIN}}") \
  ifelse(VARNISH_CLI_TIMEOUT, {{}}, {{}}, -e "{{{{VARNISH_CLI_TIMEOUT}}}}={{VARNISH_CLI_TIMEOUT}}") \
  ifelse(VARNISH_SESS_TIMEOUT, {{}}, {{}}, -e "{{{{VARNISH_SESS_TIMEOUT}}}}={{VARNISH_SESS_TIMEOUT}}") \
  ifelse(CONFD_PREFIX, {{}}, {{}}, -e "{{{{CONFD_PREFIX}}}}={{CONFD_PREFIX}}") \
  -e "ETCD_HOST=${COREOS_PRIVATE_IPV4}" \
  DOCKER_IMAGE

ExecStop=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStopPost=-/usr/bin/docker rm DOCKER_NAME
TimeoutStopSec=DOCKER_STOP_TIMEOUT{{s}}

Restart=always
RestartSec=10s

[Install]
WantedBy=multi-user.target

[X-Fleet]
ifelse(FLEET_CONFLICTS, {{}}, {{}}, Conflicts=FLEET_CONFLICTS)

