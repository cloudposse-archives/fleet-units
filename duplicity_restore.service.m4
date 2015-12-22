changequote({{,}})dnl
define(DOCKER_NAME, duplicity)dnl
define(DOCKER_IMAGE, cloudposse/library:duplicity)dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl
define(DOCKER_VOLUME, /tmp/test)dnl
define(DOCKER_MEMORY, 2g)dnl
define(DOCKER_CPU_SHARES, 50)dnl
define(AWS_ACCESS_KEY_ID, aws-access-key-id)dnl 
define(AWS_SECRET_ACCESS_KEY, aws-secret-access-key)dnl 
define(BACKUP_PATH, /var/www/html)dnl
define(BACKUP_TARGET, s3://s3.amazonaws.com/<bucket_name>/backup)dnl
define(BACKUP_RESTORE_POINT, 1D)dnl


[Unit]
Description=Backup DOCKER_VOLUME to BACKUP_TARGET
Requires=docker.service
After=docker.service
Requires=flanneld.service
After=flanneld.service
Requires=BACKUP_MACHINE_NAME
After=BACKUP_MACHINE_NAME


[Service]
User=core
Type=oneshot
RemainAfterExit=no
EnvironmentFile=/etc/environment
EnvironmentFile=/etc/env.d/*
TimeoutStartSec=0
ExecStartPre=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStartPre=-/usr/bin/docker rm DOCKER_NAME
ExecStartPre=-/usr/bin/docker --debug=true pull DOCKER_IMAGE

ExecStart=/usr/bin/docker run \     
                          --name=DOCKER_NAME \
                          --rm \
                          ifelse(DOCKER_MEMORY, {{}}, {{}}, --memory={{DOCKER_MEMORY}}) \
                          ifelse(DOCKER_CPU_SHARES, {{}}, {{}}, --cpu-shares={{DOCKER_CPU_SHARES}}) \
                          -e '{{AWS_ACCESS_KEY_ID}}=AWS_ACCESS_KEY_ID' \
                          -e '{{AWS_SECRET_ACCESS_KEY}}=AWS_SECRET_ACCESS_KEY' \
                          --volume DOCKER_VOLUME \
                          DOCKER_IMAGE \
                            -v 8  -t BACKUP_RESTORE_POINT --s3-use-new-style --no-encryption --force BACKUP_TARGET BACKUP_PATH

ExecStop=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStopPost=-/usr/bin/docker rm DOCKER_NAME
TimeoutStopSec=DOCKER_STOP_TIMEOUT{{s}}

[Install]
WantedBy=multi-user.target
