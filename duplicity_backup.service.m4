changequote({{,}})dnl
define(DOCKER_NAME, duplicity)dnl
define(DOCKER_IMAGE, cloudposse/duplicity:latest)dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl
define(DOCKER_VOLUME, /tmp/test)dnl
define(DOCKER_MEMORY, 2g)dnl
define(DOCKER_CPU_SHARES, 50)dnl
define(AWS_ACCESS_KEY_ID, aws-access-key-id)dnl 
define(AWS_SECRET_ACCESS_KEY, aws-secret-access-key)dnl 
define(BACKUP_MACHINE_NAME, )dnl
define(BACKUP_MACHINE_SERVICE, {{BACKUP_MACHINE_NAME}}.service)dnl 
define(BACKUP_TARGET, s3://s3.amazonaws.com/<bucket_name>/backup)dnl
define(BACKUP_PATH, /tmp/)dnl
define(BACKUP_INTERVAL, 60)dnl
define(BACKUP_COUNT, 3)dnl
define(MAX_LOAD_AVG, 6.00)dnl

[Unit]
Description=Backup DOCKER_VOLUME to BACKUP_TARGET  on BACKUP_MACHINE_NAME
Requires=docker.service
After=docker.service
Requires=flanneld.service
After=flanneld.service
Requires=BACKUP_MACHINE_SERVICE
After=BACKUP_MACHINE_SERVICE


[Service]
User=core
Type=oneshot
RemainAfterExit=no
EnvironmentFile=/etc/environment
EnvironmentFile=/etc/env.d/*
# Ensure load average does not execeed MAX_LOAD_AVG
ExecStartPre=/bin/bash -c 'echo | awk -v n1="$(cat /proc/loadavg | cut -d " " -f1)" -v n2=MAX_LOAD_AVG "{ if (n1 > n2){ printf (\"Load average %.2f exceeds %.2f\\n\", n1, n2); exit(1);} exit(0); }"'
ExecStartPre=-/usr/bin/docker --debug=true pull DOCKER_IMAGE

# Perform an incremental backup
ExecStart=/usr/bin/docker run \     
                            --name=DOCKER_NAME \
                            --rm \
                            ifelse(DOCKER_VOLUME, {{}}, {{}}, --volume {{DOCKER_VOLUME}}) \
                            ifelse(DOCKER_MEMORY, {{}}, {{}}, --memory={{DOCKER_MEMORY}}) \
                            ifelse(DOCKER_CPU_SHARES, {{}}, {{}}, --cpu-shares={{DOCKER_CPU_SHARES}}) \
                            -e '{{AWS_ACCESS_KEY_ID}}=AWS_ACCESS_KEY_ID' \
                            -e '{{AWS_SECRET_ACCESS_KEY}}=AWS_SECRET_ACCESS_KEY' \
                            --volume DOCKER_VOLUME \
                            --entrypoint=/usr/bin/duplicity \
                            DOCKER_IMAGE \
                              incr --no-encryption --allow-source-mismatch --s3-use-new-style --full-if-older-than 7D BACKUP_PATH BACKUP_TARGET

# Remove old backups
ExecStartPost=/usr/bin/docker run \     
                            --name=DOCKER_NAME \
                            --rm \
                            ifelse(DOCKER_VOLUME, {{}}, {{}}, --volume {{DOCKER_VOLUME}}) \
                            ifelse(DOCKER_MEMORY, {{}}, {{}}, --memory={{DOCKER_MEMORY}}) \
                            ifelse(DOCKER_CPU_SHARES, {{}}, {{}}, --cpu-shares={{DOCKER_CPU_SHARES}}) \
                            -e '{{AWS_ACCESS_KEY_ID}}=AWS_ACCESS_KEY_ID' \
                            -e '{{AWS_SECRET_ACCESS_KEY}}=AWS_SECRET_ACCESS_KEY' \
                            --volume DOCKER_VOLUME \
                            --entrypoint=/usr/bin/duplicity \
                            DOCKER_IMAGE \
                              remove-all-but-n-full $BACKUP_COUNT --force --s3-use-new-style --no-encryption --allow-source-mismatch BACKUP_TARGET 

# Cleanup
ExecStartPost=/usr/bin/docker run \     
                            --name=DOCKER_NAME \
                            --rm \
                            ifelse(DOCKER_VOLUME, {{}}, {{}}, --volume {{DOCKER_VOLUME}}) \
                            ifelse(DOCKER_MEMORY, {{}}, {{}}, --memory={{DOCKER_MEMORY}}) \
                            ifelse(DOCKER_CPU_SHARES, {{}}, {{}}, --cpu-shares={{DOCKER_CPU_SHARES}}) \
                            -e '{{AWS_ACCESS_KEY_ID}}=AWS_ACCESS_KEY_ID' \
                            -e '{{AWS_SECRET_ACCESS_KEY}}=AWS_SECRET_ACCESS_KEY' \
                            --volume DOCKER_VOLUME \
                            --entrypoint=/usr/bin/duplicity \
                            DOCKER_IMAGE \
                              cleanup --force --s3-use-new-style --no-encryption BACKUP_TARGET

ExecStop=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStopPost=-/usr/bin/docker rm DOCKER_NAME
TimeoutStopSec=DOCKER_STOP_TIMEOUT{{s}}

[Install]
WantedBy=multi-user.target
WantedBy=BACKUP_MACHINE_SERVICE

[X-Fleet]
MachineOf=BACKUP_MACHINE_SERVICE

