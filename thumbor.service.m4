changequote({{,}})dnl
define(REDIS_QUEUE_SERVER_HOST, )dnl
define(REDIS_QUEUE_SERVER_PORT, )dnl
define(REDIS_QUEUE_SERVER_PASSWORD, )dnl
define(REDIS_QUEUE_SERVER_DB, )dnl
define(REDIS_STORAGE_SERVER_HOST, )dnl
define(REDIS_STORAGE_SERVER_PORT, )dnl
define(REDIS_STORAGE_SERVER_PASSWORD, )dnl
define(REDIS_STORAGE_SERVER_DB, )dnl
define(SECURITY_KEY, )dnl
define(DETECTORS, )dnl
define(STORAGE, )dnl
define(MIXED_STORAGE_DETECTOR_STORAGE, )dnl
define(AUTO_WEBP, )dnl
define(USE_GIFSICLE_ENGINE, )dnl
define(LOG_LEVEL, )dnl
define(SERVICE_PORTS, )dnl
define(SERVICE_LOGS, )dnl
define(DOCKER_NAME, )dnl
define(DOCKER_TAG, latest)dnl
define(DOCKER_REGISTRY, index.docker.io)dnl
define(DOCKER_REPOSITORY, cloudposse/thumbor)dnl
define(DOCKER_IMAGE, {{DOCKER_REGISTRY}}/{{DOCKER_REPOSITORY}}:{{DOCKER_TAG}})dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl
define(DOCKER_VOLUME, )dnl
define(DOCKER_LOGS, )dnl
define(DOCKER_DNS, ${DNS_SERVER})dnl
define(DOCKER_DNS_SEARCH, )dnl
define(DOCKER_MEMORY, 500m)dnl
define(DOCKER_CPU_SHARES, 100)dnl
define(DNS_SERVICE_NAME, )dnl
define(DNS_SERVICE_ID, %H)dnl
define(FLEET_CONFLICTS, %p@*)dnl

[Unit]
Description=Thumbor (DOCKER_NAME) Service
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
ExecStartPre=-/usr/bin/docker {{--debug=true}} pull DOCKER_IMAGE
ExecStart=/usr/bin/docker run --name DOCKER_NAME \
                              --rm \
                              ifelse(DOCKER_MEMORY, {{}}, {{}}, --memory={{DOCKER_MEMORY}}) \
                              ifelse(DOCKER_CPU_SHARES, {{}}, {{}}, --cpu-shares={{DOCKER_CPU_SHARES}}) \
                              ifelse(DOCKER_DNS, {{}}, {{}}, --dns={{DOCKER_DNS}}) \
                              ifelse(DOCKER_DNS_SEARCH, {{}}, {{}}, --dns-search={{DOCKER_DNS_SEARCH}}) \
                              ifelse(DOCKER_VOLUME, {{}}, {{}}, --volume {{DOCKER_VOLUME}}) \
                              ifelse(DOCKER_LOGS, {{}}, {{}}, --volume {{DOCKER_LOGS}}) \
                              ifelse(SERVICE_LOGS, {{}}, {{}}, --volume {{SERVICE_LOGS}}) \
                              ifelse(SERVICE_PORTS, {{}}, {{}}, -p {{SERVICE_PORTS}}) \
                              ifelse(REDIS_QUEUE_SERVER_PORT, {{}}, {{}}, -e "{{{{REDIS_QUEUE_SERVER_PORT}}}}={{REDIS_QUEUE_SERVER_PORT}}") \
                              ifelse(REDIS_QUEUE_SERVER_PASSWORD, {{}}, {{}}, -e "{{{{REDIS_QUEUE_SERVER_PASSWORD}}}}={{REDIS_QUEUE_SERVER_PASSWORD}}") \
                              ifelse(REDIS_QUEUE_SERVER_HOST, {{}}, {{}}, -e "{{{{REDIS_QUEUE_SERVER_HOST}}}}={{REDIS_QUEUE_SERVER_HOST}}") \
                              ifelse(REDIS_QUEUE_SERVER_DB, {{}}, {{}}, -e "{{{{REDIS_QUEUE_SERVER_DB}}}}={{REDIS_QUEUE_SERVER_DB}}") \
                              ifelse(REDIS_STORAGE_SERVER_PORT, {{}}, {{}}, -e "{{{{REDIS_STORAGE_SERVER_PORT}}}}={{REDIS_STORAGE_SERVER_PORT}}") \
                              ifelse(REDIS_STORAGE_SERVER_PASSWORD, {{}}, {{}}, -e "{{{{REDIS_STORAGE_SERVER_PASSWORD}}}}={{REDIS_STORAGE_SERVER_PASSWORD}}") \
                              ifelse(REDIS_STORAGE_SERVER_HOST, {{}}, {{}}, -e "{{{{REDIS_STORAGE_SERVER_HOST}}}}={{REDIS_STORAGE_SERVER_HOST}}") \
                              ifelse(REDIS_STORAGE_SERVER_DB, {{}}, {{}}, -e "{{{{REDIS_STORAGE_SERVER_DB}}}}={{REDIS_STORAGE_SERVER_DB}}") \
                              ifelse(MIXED_STORAGE_DETECTOR_STORAGE, {{}}, {{}}, -e "{{{{MIXED_STORAGE_DETECTOR_STORAGE}}}}={{MIXED_STORAGE_DETECTOR_STORAGE}}") \
                              ifelse(STORAGE, {{}}, {{}}, -e "{{{{STORAGE}}}}={{STORAGE}}") \
                              ifelse(DETECTORS, {{}}, {{}}, -e "{{{{DETECTORS}}}}={{DETECTORS}}") \
                              ifelse(SECURITY_KEY, {{}}, {{}}, -e "{{{{SECURITY_KEY}}}}={{SECURITY_KEY}}") \
                              ifelse(AUTO_WEBP, {{}}, {{}}, -e "{{{{AUTO_WEBP}}}}={{AUTO_WEBP}}") \
                              ifelse(USE_GIFSICLE_ENGINE, {{}}, {{}}, -e "{{{{USE_GIFSICLE_ENGINE}}}}={{USE_GIFSICLE_ENGINE}}") \
                              ifelse(LOG_LEVEL, {{}}, {{}}, -e "{{{{LOG_LEVEL}}}}={{LOG_LEVEL}}") \
                              -e "SERVICE_NAME=DNS_SERVICE_NAME" \
                              -e "SERVICE_ID=DNS_SERVICE_ID" \
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

