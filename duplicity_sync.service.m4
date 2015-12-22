changequote({{,}})dnl
define(DOCKER_NAME, duplicity)dnl
define(DOCKER_IMAGE, cloudposse/library:duplicity)dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl
define(DOCKER_VOLUME, /tmp/test)dnl
define(DOCKER_MEMORY, 2g)dnl
define(DOCKER_CPU_SHARES, 50)dnl
define(AWS_ACCESS_KEY_ID, aws-access-key-id)dnl 
define(AWS_SECRET_ACCESS_KEY, aws-secret-access-key)dnl 
define(BACKUP_NAME, some-container)dnl
define(BACKUP_SERVICE, {{BACKUP_NAME}}.service)dnl
define(BACKUP_TARGET, s3://s3.amazonaws.com/<bucket_name>/backup)dnl
define(BACKUP_INTERVAL, 60)dnl
define(BACKUP_COUNT, 3)dnl


[Unit]
Description=Backup DOCKER_VOLUME to BACKUP_TARGET
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
ExecStartPre=/usr/bin/sh -c "echo DOCKER_VOLUME | cut -d: -f1 | xargs mkdir -p -m 1777"

ExecStart=/usr/bin/sh -c "/usr/bin/docker run \     
                                          --name=DOCKER_NAME \
                                          ifelse(DOCKER_MEMORY, {{}}, {{}}, --memory={{DOCKER_MEMORY}}) \
                                          ifelse(DOCKER_CPU_SHARES, {{}}, {{}}, --cpu-shares={{DOCKER_CPU_SHARES}}) \
                                          -e '{{AWS_ACCESS_KEY_ID}}=AWS_ACCESS_KEY_ID' \
                                          -e '{{AWS_SECRET_ACCESS_KEY}}=AWS_SECRET_ACCESS_KEY' \
                                          --volume DOCKER_VOLUME \
                                          DOCKER_IMAGE \
                                          $(echo DOCKER_VOLUME|cut -d':' -f2) BACKUP_TARGET BACKUP_INTERVAL BACKUP_COUNT"

ExecStop=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStopPost=-/usr/bin/docker rm DOCKER_NAME
TimeoutStopSec=DOCKER_STOP_TIMEOUT{{s}}

RestartSec=60s
Restart=always
TimeoutStopSec=60s
[Install]
WantedBy=multi-user.target

[X-Fleet]
MachineOf=BACKUP_SERVICE

