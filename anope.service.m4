changequote({{,}})dnl
define(DOCKER_NAME, )dnl
define(DOCKER_TAG, latest)dnl
define(DOCKER_REGISTRY, index.docker.io)dnl
define(DOCKER_REPOSITORY, {{cloudposse/anope}})dnl
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
define(SERVICE_PORTS, )dnl
define(SERVICE_LOGS, )dnl
define(FLEET_GLOBAL_SERVICE, {{false}})dnl
define(FLEET_MACHINE_OF, )dnl
define(FLEET_MACHINE_OF_SERVICE, {{FLEET_MACHINE_OF}}.service)dnl
define(FLEET_CONFLICTS_WITH, )dnl
define(FLEET_CONFLICTS_WITH_SERVICE, {{FLEET_CONFLICTS_WITH}}.service)dnl
define(ANOPE_SMTP_HOST, 127.0.0.1)dnl
define(ANOPE_ADMIN_EMAIL, {{ops@ourdomain.com}})dnl
define(ANOPE_NAMESERVERS, 8.8.8.8 8.8.4.4)dnl
define(ANOPE_UPLINK_HOST, {{irc.ourdomain.com}})dnl
define(ANOPE_UPLINK_PORT, 7000)dnl
define(ANOPE_UPLINK_PASSWORD, secret)dnl
define(ANOPE_SERVERINFO_NAME, {{anope.localnet}})dnl
define(ANOPE_SALT, {{salty}})dnl
define(ANOPE_URL, )dnl
define(MYSQL_USER, root)dnl
define(MYSQL_PASSWORD, {{password}})dnl
define(MYSQL_HOST, {{localhost}})dnl
define(MYSQL_PORT, 3306)dnl
define(MYSQL_DATABASE, foobar)dnl
define(MYSQL_PREFIX, anope_)dnl

[Unit]
Description=DOCKER_NAME Service
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
                              ifelse(DOCKER_MEMORY, {{}}, {{}}, --memory={{DOCKER_MEMORY}}) \
                              ifelse(DOCKER_CPU_SHARES, {{}}, {{}}, --cpu-shares={{DOCKER_CPU_SHARES}}) \
                              ifelse(DOCKER_DNS, {{}}, {{}}, --dns={{DOCKER_DNS}}) \
                              ifelse(DOCKER_DNS_SEARCH, {{}}, {{}}, --dns-search={{DOCKER_DNS_SEARCH}}) \
                              ifelse(DOCKER_VOLUME, {{}}, {{}}, --volume {{DOCKER_VOLUME}}) \
                              ifelse(DOCKER_LOGS, {{}}, {{}}, --volume {{DOCKER_LOGS}}) \
                              ifelse(SERVICE_LOGS, {{}}, {{}}, --volume {{SERVICE_LOGS}}) \
                              ifelse(SERVICE_PORTS, {{}}, {{}}, -p {{SERVICE_PORTS}}) \
                              -e "SERVICE_NAME=DNS_SERVICE_NAME" \
                              -e "SERVICE_ID=DNS_SERVICE_ID" \
                              ifelse(MYSQL_USER, {{}}, {{}}, -e "{{{{MYSQL_USER}}}}={{MYSQL_USER}}") \
                              ifelse(MYSQL_PASSWORD, {{}}, {{}}, -e "{{{{MYSQL_PASSWORD}}}}={{MYSQL_PASSWORD}}") \
                              ifelse(MYSQL_HOST, {{}}, {{}}, -e "{{{{MYSQL_HOST}}}}={{MYSQL_HOST}}") \
                              ifelse(MYSQL_DATABASE, {{}}, {{}}, -e "{{{{MYSQL_DATABASE}}}}={{MYSQL_DATABASE}}") \
                              ifelse(MYSQL_PORT, {{}}, {{}}, -e "{{{{MYSQL_PORT}}}}={{MYSQL_PORT}}") \
                              ifelse(MYSQL_PREFIX, {{}}, {{}}, -e "{{{{MYSQL_PREFIX}}}}={{MYSQL_PREFIX}}") \
                              ifelse(ANOPE_SMTP_HOST, {{}}, {{}}, -e "{{{{ANOPE_SMTP_HOST}}}}={{ANOPE_SMTP_HOST}}") \
                              ifelse(ANOPE_ADMIN_EMAIL, {{}}, {{}}, -e "{{{{ANOPE_ADMIN_EMAIL}}}}={{ANOPE_ADMIN_EMAIL}}") \
                              ifelse(ANOPE_NAMESERVERS, {{}}, {{}}, -e "{{{{ANOPE_NAMESERVERS}}}}={{ANOPE_NAMESERVERS}}") \
                              ifelse(ANOPE_UPLINK_HOST, {{}}, {{}}, -e "{{{{ANOPE_UPLINK_HOST}}}}={{ANOPE_UPLINK_HOST}}") \
                              ifelse(ANOPE_UPLINK_PORT, {{}}, {{}}, -e "{{{{ANOPE_UPLINK_PORT}}}}={{ANOPE_UPLINK_PORT}}") \
                              ifelse(ANOPE_UPLINK_PASSWORD, {{}}, {{}}, -e "{{{{ANOPE_UPLINK_PASSWORD}}}}={{ANOPE_UPLINK_PASSWORD}}") \
                              ifelse(ANOPE_SERVERINFO_NAME, {{}}, {{}}, -e "{{{{ANOPE_SERVERINFO_NAME}}}}={{ANOPE_SERVERINFO_NAME}}") \
                              ifelse(ANOPE_SALT, {{}}, {{}}, -e "{{{{ANOPE_SALT}}}}={{ANOPE_SALT}}") \
                              ifelse(ANOPE_URL, {{}}, {{}}, -e "{{{{ANOPE_URL}}}}={{ANOPE_URL}}") \
                              DOCKER_IMAGE

ExecStop=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStopPost=-/usr/bin/docker rm DOCKER_NAME
TimeoutStopSec=DOCKER_STOP_TIMEOUT{{s}}

Restart=always
RestartSec=10s

[Install]
WantedBy=multi-user.target

[X-Fleet]
ifelse(FLEET_GLOBAL_SERVICE, {{true}}, {{{{Global=true}}}}, {{}})
ifelse(FLEET_MACHINE_OF_SERVICE, {{.service}}, {{}}, MachineOf={{FLEET_MACHINE_OF_SERVICE}})
ifelse(FLEET_CONFLICTS_WITH_SERVICE, {{.service}}, {{}}, Conflicts={{FLEET_CONFLICTS_WITH_SERVICE}})
Conflicts=fleet_disabled.service
