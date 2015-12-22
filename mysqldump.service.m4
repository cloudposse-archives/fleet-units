changequote({{,}})dnl
define(DOCKER_NAME, mysqldump)dnl
define(DOCKER_TAG, latest)dnl
define(DOCKER_REGISTRY, index.docker.io)dnl
define(DOCKER_REPOSITORY, cloudposse/mysql)dnl
define(DOCKER_IMAGE, {{DOCKER_REGISTRY}}/{{DOCKER_REPOSITORY}}:{{DOCKER_TAG}})dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl
define(DOCKER_VOLUME, /tmp/test:/tmp/test)
define(DOCKER_VOLUME_OCTAL_MODE, 1777)dnl
define(DOCKER_DNS, ${DNS_SERVER})dnl
define(DOCKER_DNS_SEARCH, )dnl
define(MYSQL_PORT, 3306)dnl
define(MYSQL_USER, root)dnl
define(MYSQL_PASS, {{password}})dnl
define(MYSQL_HOST, localhsot)dnl
define(MYSQL_DATABASE, foobar)dnl
define(MYSQL_BACKUP_FILE, /tmp/test/mysqldump.sql)dnl
dnl define(MYSQL_BACKUP_ARGS, --all-databases)
define(MYSQL_BACKUP_ARGS, )

[Unit]
Description=Trigger a mysqldump of mysql://MYSQL_USER@MYSQL_HOST:MYSQL_PORT/MYSQL_DATABASE to MYSQL_BACKUP_FILE
Requires=docker.service
After=docker.service
Requires=flanneld.service
After=flanneld.service


[Service]
User=core
EnvironmentFile=/etc/environment
EnvironmentFile=/etc/env.d/*
TimeoutStartSec=0
Type=oneshot
RemainAfterExit=no
ExecStartPre=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStartPre=-/usr/bin/docker rm DOCKER_NAME
ExecStartPre=-/usr/bin/docker --debug=true pull DOCKER_IMAGE
ExecStartPre=/usr/bin/sh -c "echo DOCKER_VOLUME | cut -d: -f1 | xargs --no-run-if-empty mkdir -p -m DOCKER_VOLUME_OCTAL_MODE"
dnl IMPORTANT: do not wrap arguments passed to mysqldump in quotes because they get doubly escaped!
ExecStart=/usr/bin/docker run \
                          --dns DOCKER_DNS \
                          ifelse(DOCKER_DNS, {{}}, {{}}, --dns={{DOCKER_DNS}}) \
                          ifelse(DOCKER_DNS_SEARCH, {{}}, {{}}, --dns-search={{DOCKER_DNS_SEARCH}}) \
                          --name DOCKER_NAME \
                          --rm \
                          --volume DOCKER_VOLUME \
                          --entrypoint=/bin/bash \
                          DOCKER_IMAGE \
                            -c 'mysqldump MYSQL_BACKUP_ARGS --result-file=MYSQL_BACKUP_FILE.tmp --user=MYSQL_USER --password=MYSQL_PASS --port=MYSQL_PORT --host=MYSQL_HOST MYSQL_DATABASE && mv -f MYSQL_BACKUP_FILE.tmp MYSQL_BACKUP_FILE'

# Compress the local backup
#ExecStartPost=/usr/bin/sh -c "echo DOCKER_VOLUME | cut -d: -f1 | xargs -I'{}' find {} -type f -name $(basename MYSQL_BACKUP_FILE) | xargs --no-run-if-empty gzip --force"


[Install]
WantedBy=multi-user.target
