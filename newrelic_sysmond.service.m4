changequote({{,}})dnl
define(DOCKER_NAME, newrelic_sysmond)dnl
define(DOCKER_REGISTRY, index.docker.io)dnl
define(DOCKER_TAG, latest)dnl
define(DOCKER_REPOSITORY, cloudposse/newrelic-sysmond:DOCKER_TAG)dnl
define(DOCKER_IMAGE, DOCKER_REGISTRY/DOCKER_REPOSITORY)dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl
define(DNS_SERVICE_NAME, newrelic)dnl
define(DNS_SERVICE_ID, %H)dnl
define(NEWRELIC_LICENSE_KEY, )dnl
define(NEWRELIC_LOG_LEVEL, info)dnl
define(NEWRELIC_HOSTNAME, %H)dnl


[Unit]
Description=NewRelic Sysmond
Requires=docker.service
After=docker.service
Requires=flanneld.service
After=flanneld.service


[Service]
User=core
EnvironmentFile=/etc/environment
EnvironmentFile=/etc/env.d/*
TimeoutStartSec=0
ExecStartPre=-/bin/sh -c "docker inspect DOCKER_NAME >/dev/null && docker rm -f DOCKER_NAME"
ExecStartPre=-/usr/bin/docker --debug=true pull DOCKER_IMAGE
ExecStart=/usr/bin/docker run \
                          --rm \
                          --name DOCKER_NAME \
                          --net=host \
                          -e "{{NEWRELIC_LICENSE_KEY}}=NEWRELIC_LICENSE_KEY" \
                          -e "{{NEWRELIC_HOSTNAME}}=NEWRELIC_HOSTNAME" \
                          -e "{{NEWRELIC_LOG_LEVEL}}=NEWRELIC_LOG_LEVEL" \
                          -v /var/run/docker.sock:/var/run/docker.sock \
                          DOCKER_IMAGE
ExecStop=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStopPost=-/usr/bin/docker rm DOCKER_NAME
TimeoutStopSec=DOCKER_STOP_TIMEOUT{{s}}
Restart=always
RestartSec=30

[Install]
WantedBy=multi-user.target

[X-Fleet]
Global=true
