changequote({{,}})dnl
define(DOCKER_NAME, mysql-galera)dnl
define(DOCKER_IMAGE, cloudposse/library:mysql-galera)dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl
define(MYSQL_CLUSTER, default)dnl
define(MYSQL_PORT, 3306)dnl
define(MYSQL_RSYNC_PORT, 4444)dnl
define(MYSQL_GROUP_PORT, 4567)dnl
define(MYSQL_INCR_PORT, 4568)dnl
define(MYSQL_USER, root)dnl
define(MYSQL_PASS, password)dnl

# FIXME: need to add support for data-vol

[Unit]
Description=MySQL Galera Server by Percona
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
ExecStart=/usr/bin/docker run \
                          --name DOCKER_NAME \
                          -p MYSQL_PORT:3306 \
                          -p MYSQL_RSYNC_PORT:4444 \
                          -p MYSQL_GROUP_PORT:4567 \
                          -p MYSQL_INCR_PORT:4568 \
                          -e "{{MYSQL_USER}}=MYSQL_USER" \
                          -e "{{MYSQL_PASS}}=MYSQL_PASS" \
                          -e "HOST=$COREOS_PRIVATE_IPV4" \
                          -e "CLUSTER=MYSQL_CLUSTER" \
                          DOCKER_IMAGE

ExecStop=/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStopPost=/usr/bin/docker rm DOCKER_NAME
TimeoutStopSec=DOCKER_STOP_TIMEOUT{{s}}

[Install]
WantedBy=multi-user.target
