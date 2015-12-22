changequote({{,}})dnl
define(DOCKER_NAME, elasticsearch)dnl
define(DOCKER_REGISTRY, index.docker.io)dnl
define(DOCKER_TAG, {{{{kibana}}}})dnl
define(DOCKER_REPOSITORY, {{cloudposse/library}}:{{DOCKER_TAG}})dnl
define(DOCKER_IMAGE, {{DOCKER_REGISTRY}}/{{DOCKER_REPOSITORY}})dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl
define(DOCKER_VOLUME, /tmp/elasticsearch:/var/lib/elasticsearch)dnl
define(DOCKER_VOLUME_OCTAL_MODE, 1777)dnl
define(DOCKER_DNS, ${DNS_SERVER})dnl
define(DOCKER_HOSTNAME, )dnl
define(DNS_SERVICE_NAME, {{kibana}})dnl
define(DNS_SERVICE_ID, {{%H}})dnl
define(ELASTICSEARCH_SCHEME, http)dnl
define(ELASTICSEARCH_HOST, elasticsearch.ourcloud.local)dnl
define(ELASTICSEARCH_PORT, 9200)dnl

[Unit]
Description=Kibana Elastic Search Frontend
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
ExecStartPre=/usr/bin/sh -c "echo DOCKER_VOLUME | cut -d: -f1 | xargs mkdir -p -m DOCKER_VOLUME_OCTAL_MODE"
ExecStart=/usr/bin/docker run \
                          --name DOCKER_NAME \
                          --rm \
                          ifelse(DOCKER_DNS, {{}}, {{}}, --dns {{DOCKER_DNS}}) \
                          ifelse(DOCKER_HOSTNAME, {{}}, {{}}, --hostname {{DOCKER_HOSTNAME}}) \
                          ifelse(DOCKER_VOLUME, {{}}, {{}}, --volume {{DOCKER_VOLUME}}) \
                          -e "{{ELASTICSEARCH_SCHEME}}=ELASTICSEARCH_SCHEME" \
                          -e "{{ELASTICSEARCH_HOST}}=ELASTICSEARCH_HOST" \
                          -e "{{ELASTICSEARCH_PORT}}=ELASTICSEARCH_PORT" \
                          -e "SERVICE_5601_NAME=DNS_SERVICE_NAME" \
                          -e "SERVICE_5601_ID=DNS_SERVICE_ID" \
                          DOCKER_IMAGE

ExecStop=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStopPost=-/usr/bin/docker rm DOCKER_NAME
TimeoutStopSec=DOCKER_STOP_TIMEOUT{{s}}

RestartSec=10s
Restart=always

[Install]
WantedBy=multi-user.target
