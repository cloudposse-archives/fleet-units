changequote({{,}})dnl
define(DOCKER_NAME, )dnl
define(DOCKER_TAG, {{unrealircd}})dnl
define(DOCKER_REGISTRY, index.docker.io)dnl
define(DOCKER_REPOSITORY, cloudposse/library)dnl
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
define(INSPIRCD_SERVER_NAME, irc.localhost)dnl
define(INSPIRCD_SERVER_DESCRIPTION, IRC Chat Network)dnl
define(INSPIRCD_NETWORK, ChatNet)dnl
define(INSPIRCD_ADMIN_NAME, Admin)dnl
define(INSPIRCD_ADMIN_NICK, admin)dnl
define(INSPIRCD_ADMIN_EMAIL, support@localhost)dnl
define(INSPIRCD_LINK_NAME, anope.localhost)dnl
define(INSPIRCD_LINK_PORT, 7000)dnl
define(INSPIRCD_LINK_SEND_PASS, super-secret)dnl
define(INSPIRCD_LINK_RECV_PASS, another-secret)dnl
define(INSPIRCD_CGIHOST_WEBIRC_PASSWORD, password)dnl
define(INSPIRCD_CLOAK_KEY, token)dnl
define(INSPIRCD_STATS_USERNAME, stats)dnl
define(INSPIRCD_STATS_PASSWORD, password)dnl
define(INSPIRCD_SQLLOG_QUERY, INSERT INTO events (nick, host, ip, user_name, ident, server, channel, event, message) VALUES ('$nick', '$host', '$ip', '$gecos', '$ident', '$server', '$channel', '$event', '$message'))dnl
define(MYSQL_USER, root)dnl
define(MYSQL_PASSWORD, {{password}})dnl
define(MYSQL_HOST, localhost)dnl
define(MYSQL_PORT, 3306)dnl
define(MYSQL_DATABASE, foobar)dnl

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
                              ifelse(INSPIRCD_SERVER_NAME, {{}}, {{}}, -e "{{{{INSPIRCD_SERVER_NAME}}}}={{INSPIRCD_SERVER_NAME}}") \
                              ifelse(INSPIRCD_SERVER_DESCRIPTION, {{}}, {{}}, -e "{{{{INSPIRCD_SERVER_DESCRIPTION}}}}={{INSPIRCD_SERVER_DESCRIPTION}}") \
                              ifelse(INSPIRCD_NETWORK, {{}}, {{}}, -e "{{{{INSPIRCD_NETWORK}}}}={{INSPIRCD_NETWORK}}") \
                              ifelse(INSPIRCD_ADMIN_NAME, {{}}, {{}}, -e "{{{{INSPIRCD_ADMIN_NAME}}}}={{INSPIRCD_ADMIN_NAME}}") \
                              ifelse(INSPIRCD_ADMIN_NICK, {{}}, {{}}, -e "{{{{INSPIRCD_ADMIN_NICK}}}}={{INSPIRCD_ADMIN_NICK}}") \
                              ifelse(INSPIRCD_ADMIN_EMAIL, {{}}, {{}}, -e "{{{{INSPIRCD_ADMIN_EMAIL}}}}={{INSPIRCD_ADMIN_EMAIL}}") \
                              ifelse(INSPIRCD_LINK_NAME, {{}}, {{}}, -e "{{{{INSPIRCD_LINK_NAME}}}}={{INSPIRCD_LINK_NAME}}") \
                              ifelse(INSPIRCD_LINK_PORT, {{}}, {{}}, -e "{{{{INSPIRCD_LINK_PORT}}}}={{INSPIRCD_LINK_PORT}}") \
                              ifelse(INSPIRCD_LINK_SEND_PASS, {{}}, {{}}, -e "{{{{INSPIRCD_LINK_SEND_PASS}}}}={{INSPIRCD_LINK_SEND_PASS}}") \
                              ifelse(INSPIRCD_LINK_RECV_PASS, {{}}, {{}}, -e "{{{{INSPIRCD_LINK_RECV_PASS}}}}={{INSPIRCD_LINK_RECV_PASS}}") \
                              ifelse(INSPIRCD_CGIHOST_WEBIRC_PASSWORD, {{}}, {{}}, -e "{{{{INSPIRCD_CGIHOST_WEBIRC_PASSWORD}}}}={{INSPIRCD_CGIHOST_WEBIRC_PASSWORD}}") \
                              ifelse(INSPIRCD_CLOAK_KEY, {{}}, {{}}, -e "{{{{INSPIRCD_CLOAK_KEY}}}}={{INSPIRCD_CLOAK_KEY}}") \
                              ifelse(INSPIRCD_STATS_USERNAME, {{}}, {{}}, -e "{{{{INSPIRCD_STATS_USERNAME}}}}={{INSPIRCD_STATS_USERNAME}}") \
                              ifelse(INSPIRCD_STATS_PASSWORD, {{}}, {{}}, -e "{{{{INSPIRCD_STATS_PASSWORD}}}}={{INSPIRCD_STATS_PASSWORD}}") \
                              ifelse(INSPIRCD_SQLLOG_QUERY, {{}}, {{}}, -e "{{{{INSPIRCD_SQLLOG_QUERY}}}}={{INSPIRCD_SQLLOG_QUERY}}") \
                              ifelse(MYSQL_USER, {{}}, {{}}, -e "{{{{MYSQL_USER}}}}={{MYSQL_USER}}") \
                              ifelse(MYSQL_PASSWORD, {{}}, {{}}, -e "{{{{MYSQL_PASSWORD}}}}={{MYSQL_PASSWORD}}") \
                              ifelse(MYSQL_HOST, {{}}, {{}}, -e "{{{{MYSQL_HOST}}}}={{MYSQL_HOST}}") \
                              ifelse(MYSQL_DATABASE, {{}}, {{}}, -e "{{{{MYSQL_DATABASE}}}}={{MYSQL_DATABASE}}") \
                              ifelse(MYSQL_PORT, {{}}, {{}}, -e "{{{{MYSQL_PORT}}}}={{MYSQL_PORT}}") \
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
