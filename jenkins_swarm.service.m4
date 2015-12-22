changequote({{,}})dnl
define(DOCKER_NAME, jenkins_slave)dnl
define(DOCKER_IMAGE, cloudposse/library:jenkins-swarm-slave)dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl
define(DOCKER_DNS, ${DNS_SERVER})dnl
define(DNS_SERVICE_NAME, swarm)dnl
define(DNS_SERVICE_ID, %H)dnl
define(JENKINS_HOME, /home/jenkins)dnl
define(JENKINS_MASTER_HOST, localhost)dnl
define(JENKINS_MASTER_PORT, 8080)dnl
define(JENKINS_SLAVE_NAME, DOCKER_NAME)dnl
define(JENKINS_SLAVE_USERNAME, jenkins)dnl
define(JENKINS_SLAVE_PASSWORD, password)dnl
define(JENKINS_SLAVE_MODE, normal)dnl
define(JENKINS_SLAVE_EXECUTORS, 1)dnl
define(FLEET_CONFLICTS, %p@*)dnl

[Unit]
Description=Jenkins Swarm Slave
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
                          --dns DOCKER_DNS \
                          --name DOCKER_NAME \
                          --rm \
                          ifelse(DOCKER_HOSTNAME, {{none}}, {{}}, --hostname {{DOCKER_HOSTNAME}}) \
                          -v "JENKINS_HOME" \
                          -e "SERVICE_NAME=DNS_SERVICE_NAME" \
                          -e "SERVICE_ID=DNS_SERVICE_ID" \
                          -e "{{JENKINS_MASTER_HOST}}=JENKINS_MASTER_HOST" \
                          -e "{{JENKINS_MASTER_PORT}}=JENKINS_MASTER_PORT" \
                          -e "{{JENKINS_SLAVE_USERNAME}}=JENKINS_SLAVE_USERNAME" \
                          -e "{{JENKINS_SLAVE_PASSWORD}}=JENKINS_SLAVE_PASSWORD" \
                          -e "{{JENKINS_SLAVE_MODE}}=JENKINS_SLAVE_MODE" \
                          -e "{{JENKINS_SLAVE_NAME}}=JENKINS_SLAVE_NAME" \
                          -e "{{JENKINS_SLAVE_EXECUTORS}}=JENKINS_SLAVE_EXECUTORS" \
                          DOCKER_IMAGE

ExecStop=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStopPost=-/usr/bin/docker rm DOCKER_NAME
TimeoutStopSec=DOCKER_STOP_TIMEOUT{{s}}

RestartSec=10s
Restart=always

[Install]
WantedBy=multi-user.target

[X-Fleet]
ifelse(FLEET_CONFLICTS, {{}}, {{}}, Conflicts=FLEET_CONFLICTS)

