changequote({{,}})dnl
define(DOCKER_NAME, {{mysqlhotcopy}})dnl
dnl define(DOCKER_TAG, {{mysqlhotcopy}})dnl
define(DOCKER_TAG, {{latest}})dnl
define(DOCKER_REGISTRY, {{index.docker.io}})dnl
define(DOCKER_REPOSITORY, {{cloudposse/mysql-manager}})dnl
define(DOCKER_IMAGE, {{DOCKER_REGISTRY}}/{{DOCKER_REPOSITORY}}:{{DOCKER_TAG}})dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl
define(DOCKER_VOLUME, /tmp/test:/tmp/test)
define(DOCKER_VOLUME_OCTAL_MODE, 1777)dnl
define(DOCKER_DNS, ${DNS_SERVER})dnl
define(DOCKER_DNS_SEARCH, )dnl
define(MYSQL_NAME, {{mysql-docker}})dnl
define(MYSQL_SERVICE, {{MYSQL_NAME}}.service)dnl
define(MYSQL_VOLUME, {{MYSQL_NAME}}:/var/lib/mysql:ro)
define(MYSQL_PORT, 3306)dnl
define(MYSQL_ROOT_USER, {{root}})dnl
define(MYSQL_ROOT_PASS, {{password}})dnl
define(MYSQL_HOST, {{localhost}})dnl
define(MYSQL_DATABASE, foobar)dnl
define(MYSQL_DATA_DIR, /var/lib/mysql)dnl
define(MYSQL_BACKUPS, /tmp/test/)dnl
define(RSYNC_PASSWORD, )dnl
define(MAX_LOAD_AVG, 7.00)dnl

[Unit]
Description=Trigger a mysqlhotcopy of mysql://MYSQL_USER@MYSQL_HOST:MYSQL_PORT/MYSQL_DATABASE to MYSQL_BACKUPS
Requires=docker.service
After=docker.service
Requires=flanneld.service
After=flanneld.service
Requires=MYSQL_SERVICE
After=MYSQL_SERVICE
BindTo=MYSQL_SERVICE


[Service]
User=core
EnvironmentFile=/etc/environment
EnvironmentFile=/etc/env.d/*
TimeoutStartSec=0
Type=oneshot
RemainAfterExit=no
ExecStartPre=/bin/bash -c 'until (echo | awk -v n1="$(cat /proc/loadavg | cut -d " " -f1)" -v n2=MAX_LOAD_AVG "{ if (n1 > n2){ printf (\\"Load average %.2f exceeds %.2f\\n\\", n1, n2); exit(1);} exit(0); }"); do sleep 10; done'
ExecStartPre=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStartPre=-/usr/bin/docker rm DOCKER_NAME
ExecStartPre=-/usr/bin/docker --debug=true pull DOCKER_IMAGE
ExecStartPre=/usr/bin/sh -c "echo DOCKER_VOLUME | cut -d: -f1 | xargs --no-run-if-empty mkdir -p -m DOCKER_VOLUME_OCTAL_MODE"
ExecStartPre=/usr/bin/sh -c "echo MYSQL_VOLUME | cut -d: -f1 | xargs --no-run-if-empty mkdir -p -m DOCKER_VOLUME_OCTAL_MODE"
ExecStart=/usr/bin/docker run \
                          ifelse(DOCKER_DNS, {{}}, {{}}, --dns={{DOCKER_DNS}}) \
                          ifelse(DOCKER_DNS_SEARCH, {{}}, {{}}, --dns-search={{DOCKER_DNS_SEARCH}}) \
                          --name DOCKER_NAME \
                          --rm \
                          --volume DOCKER_VOLUME \
                          --volume MYSQL_VOLUME \
                          ifelse(RSYNC_PASSWORD, {{}}, {{}}, -e "{{{{RSYNC_PASSWORD}}}}={{RSYNC_PASSWORD}}") \
                          DOCKER_IMAGE \
                           --hotcopy \
                           --hotcopy:data-dir MYSQL_DATA_DIR \
                           --hotcopy:backup-dir MYSQL_BACKUPS \
                           --hotcopy:rsync-args "-av --exclude=*.err" \
                           --hotcopy:rsync-ttl 30 \
                           --db:user MYSQL_ROOT_USER \
                           --db:pass MYSQL_ROOT_PASS \
                           --db:dsn "DBI:Mysql:mysql:MYSQL_HOST:MYSQL_PORT"
dnl                        --debug  --allowold --flushlog --method=rsync --user=MYSQL_ROOT_USER --password=MYSQL_ROOT_PASS --host=MYSQL_HOST mysql MYSQL_DATABASE MYSQL_BACKUPS


[Install]
WantedBy=multi-user.target

[X-Fleet]
MachineOf=MYSQL_SERVICE
