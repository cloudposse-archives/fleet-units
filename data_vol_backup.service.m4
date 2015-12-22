changequote({{,}})dnl
define(DOCKER_NAME, redis)dnl
define(DOCKER_IMAGE, cloudposse/library:duplicity)dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl
define(AWS_ACCESS_KEY_ID, aws-access-key-id)dnl 
define(AWS_SECRET_ACCESS_KEY, aws-secret-access-key)dnl 
define(BACKUP_DATA_VOL_NAME, data-vol)
define(BACKUP_DATA_VOL_SERVICE, {{BACKUP_DATA_VOL_NAME}}.service)dnl
define(BACKUP_TARGET, s3://s3.amazonaws.com/<bucket_name>/backup)dnl
define(BACKUP_SOURCE, /vol)dnl
define(BACKUP_INTERVAL, 60)dnl
define(BACKUP_COUNT, 3)dnl


[Unit]
Description=Backup Data Volume
Requires=docker.service
After=docker.service
Requires=flanneld.service
After=flanneld.service
After=BACKUP_DATA_VOL_SERVICE
BindTo=BACKUP_DATA_VOL_SERVICE
RequiredBy=BACKUP_DATA_VOL_SERVICE

[Service]
User=core
EnvironmentFile=/etc/environment
EnvironmentFile=/etc/env.d/*
TimeoutStartSec=0
ExecStartPre=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStartPre=-/usr/bin/docker rm DOCKER_NAME
ExecStartPre=-/usr/bin/docker --debug=true pull DOCKER_IMAGE

ExecStart=/usr/bin/docker run \     
                      --name=DOCKER_NAME \
                      --rm \ 
                      -e "{{AWS_ACCESS_KEY_ID}}=AWS_ACCESS_KEY_ID" \
                      -e "{{AWS_SECRET_ACCESS_KEY}}=AWS_SECRET_ACCESS_KEY" \
                      --volumes-from BACKUP_DATA_VOL_NAME
                      DOCKER_IMAGE \
                      BACKUP_SOURCE BACKUP_TARGET BACKUP_INTERVAL BACKUP_COUNT

ExecStop=/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStopPost=-/usr/bin/docker rm DOCKER_NAME
TimeoutStopSec=DOCKER_STOP_TIMEOUT{{s}}

[Install]
WantedBy=multi-user.target

[X-Fleet]
MachineOf=BACKUP_DATA_VOL_SERVICE

