changequote({{,}})dnl
define(DOCKER_NAME, mysql-galera-lb)dnl
define(DOCKER_IMAGE, cloudposse/library:mysql-galera)dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl
define(MYSQL_NAME, mysql-galera)dnl
define(MYSQL_SERVICE, {{MYSQL_NAME}}.service)dnl
define(MYSQL_PORT, 3307)dnl
define(MYSQL_LB_PORT, 3306)dnl
define(FLEET_GLOBAL_SERVICE, false)dnl
define(DNS_SERVICE_NAME, mysql-galera-lb)dnl
define(DNS_SERVICE_ID, %H)dnl
 
[Unit]
Description=MySQL Galera Load Balancer
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
                          -p MYSQL_LB_PORT:3306 \
                          -e "PUBLISH=MYSQL_PORT" \
                          -e "HOST=$COREOS_PRIVATE_IPV4" \
                          -e "SERVICE_NAME=DNS_SERVICE_NAME" \
                          -e "SERVICE_ID=DNS_SERVICE_ID" \
                          DOCKER_IMAGE \
                          /app/bin/loadbalancer

ExecStop=/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStopPost=-/usr/bin/docker rm DOCKER_NAME
TimeoutStopSec=DOCKER_STOP_TIMEOUT{{s}}


[Install]
WantedBy=multi-user.target

[X-Fleet]
Global=FLEET_GLOBAL_SERVICE

