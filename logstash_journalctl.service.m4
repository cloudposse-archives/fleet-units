changequote({{,}})dnl
define(DOCKER_NAME, logstash)dnl
define(DOCKER_REGISTRY, index.docker.io)dnl
define(DOCKER_TAG, {{logstash}})dnl
define(DOCKER_REPOSITORY, cloudposse/library:{{DOCKER_TAG}})dnl
define(DOCKER_IMAGE, {{DOCKER_REGISTRY}}/{{DOCKER_REPOSITORY}})dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl
define(DOCKER_DNS, ${DNS_SERVER})dnl
define(DOCKER_HOSTNAME, )dnl
define(DNS_SERVICE_NAME, {{logstash}})dnl
define(DNS_SERVICE_ID, {{{{journalctl}}}})dnl
define(ELASTICSEARCH_SCHEME, http)dnl
define(ELASTICSEARCH_HOST, elasticsearch.ourcloud.local)dnl
define(ELASTICSEARCH_PORT, 9200)dnl
define(ELASTICSEARCH_INDEX, {{journalctl}})dnl


[Unit]
Description=Logstash Journalctl Log Forwarder
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
ExecStart=/bin/sh -c '/usr/bin/journalctl -b -o json -f  | /usr/bin/docker run -i \
                          --name DOCKER_NAME \
                          --rm \
                          ifelse(DOCKER_DNS, {{}}, {{}}, --dns {{DOCKER_DNS}}) \
                          ifelse(DOCKER_HOSTNAME, {{}}, {{}}, --hostname {{DOCKER_HOSTNAME}}) \
                          -e "SERVICE_NAME=DNS_SERVICE_NAME" \
                          -e "SERVICE_ID=DNS_SERVICE_ID" \
                          --entrypoint /bin/sh \
                          DOCKER_IMAGE \
                          /logstash/bin/logstash \
                          agent \
                          --config /logstash/logstash-journalctl.conf \
                          -e "output { {{elasticsearch_}}ELASTICSEARCH_SCHEME { host => \\"ELASTICSEARCH_HOST\\" index => \\"ELASTICSEARCH_INDEX-%{+YYYY.MM.dd}\\" port => ELASTICSEARCH_PORT document_id => \\"%{__CURSOR}\\" } }"'

ExecStop=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStopPost=-/usr/bin/docker rm DOCKER_NAME
TimeoutStopSec=DOCKER_STOP_TIMEOUT{{s}}

RestartSec=10s
Restart=always

[Install]
WantedBy=multi-user.target
