changequote({{,}})dnl
define(DOCKER_NAME, mysql)dnl
define(DOCKER_VOLUME, {{none}})dnl
define(DOCKER_VOLUMES_FROM, {{none}})dnl
define(DOCKER_VOLUMES_FROM_SERVICE, {{DOCKER_VOLUMES_FROM}}.service)dnl
define(DOCKER_VOLUME_OCTAL_MODE, 1777)dnl
define(DOCKER_TAG, latest)dnl
define(DOCKER_IMAGE, cloudposse/mysql:DOCKER_TAG)dnl
define(DOCKER_STOP_TIMEOUT, 120)dnl
define(MYSQL_PORT, )dnl
define(MYSQL_USER, root)dnl
define(MYSQL_PASS, {{password}})dnl
define(MYSQL_ROOT_PASS, {{password}})dnl
define(MYSQL_DATABASE, foobar)dnl
define(MYSQL_DATA_STORAGE, )dnl
define(MYSQL_BACKUP_STORAGE, )dnl
define(MYSQL_QUERY_CACHE_TYPE, {{1}})dnl
define(MYSQL_QUERY_CACHE_LIMIT, 1M)dnl
define(MYSQL_QUERY_CACHE_SIZE, 16M)dnl
define(MYSQL_READ_RND_BUFFER_SIZE, 256K)dnl
define(MYSQL_TABLE_OPEN_CACHE, 2000)dnl
define(MYSQL_TMP_TABLE_SIZE, 32M)dnl
define(MYSQL_MAX_HEAP_TABLE_SIZE, 32M)dnl
define(MYSQL_INNODB_BUFFER_POOL_SIZE, 256M)dnl
define(MYSQL_INNODB_FLUSH_LOG_AT_TRX_COMMIT, 2)dnl
define(MYSQL_INNODB_FLUSH_METHOD, fdatasync)dnl
define(MYSQL_INNODB_LOG_BUFFER_SIZE, 1M)dnl
define(MYSQL_INNODB_FILE_PER_TABLE, ON)dnl
define(MYSQL_KEY_BUFFER_SIZE, 9M)dnl
define(MYSQL_JOIN_BUFFER_SIZE, 8M)dnl
define(MYSQL_MAX_USER_CONNECTIONS, {{150}})dnl
define(MYSQL_MAX_CONNECTIONS, {{150}})dnl
define(MYSQL_GENERAL_LOG, {{1}})dnl
define(MYSQL_EXPLICIT_DEFAULTS_FOR_TIMESTAMP, {{false}})dnl
define(MYSQL_SQL_MODE, )dnl

define(DNS_SERVICE_NAME, mysql)dnl
define(DNS_SERVICE_ID, server)dnl

define(FLEET_MACHINE_OF, )dnl
define(FLEET_MACHINE_OF_SERVICE, {{FLEET_MACHINE_OF}}.service)dnl
define(FLEET_CONFLICTS_WITH, )dnl
define(FLEET_CONFLICTS_WITH_SERVICE, {{FLEET_CONFLICTS_WITH}}.service)dnl
define(FLEET_MACHINE_METADATA, )dnl


# FIXME: need to add support for --volumes-from

[Unit]
Description=Standalone MySQL Server Community Edition ifelse(DOCKER_VOLUME, {{none}}, {{}}, on {{DOCKER_VOLUME}}) ifelse(DOCKER_VOLUMES_FROM, {{none}}, {{}}, with volumes from {{DOCKER_VOLUMES_FROM}})
Requires=docker.service
After=docker.service
Requires=flanneld.service
After=flanneld.service
ifelse(DOCKER_VOLUMES_FROM_SERVICE, {{none.service}}, {{}}, Requires={{DOCKER_VOLUMES_FROM_SERVICE}})
ifelse(DOCKER_VOLUMES_FROM_SERVICE, {{none.service}}, {{}}, After={{DOCKER_VOLUMES_FROM_SERVICE}})
ifelse(DOCKER_VOLUMES_FROM_SERVICE, {{none.service}}, {{}}, PartOf={{DOCKER_VOLUMES_FROM_SERVICE}})

[Service]
User=core
EnvironmentFile=/etc/environment
EnvironmentFile=/etc/env.d/*
TimeoutStartSec=0
ExecStartPre=-/usr/bin/docker --debug=true pull DOCKER_IMAGE

ExecStartPre=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStartPre=-/usr/bin/docker rm DOCKER_NAME

ExecStart=/usr/bin/docker run \
                          --rm \
                          --name DOCKER_NAME \
                          ifelse(DOCKER_VOLUME, {{none}}, {{}}, --volume {{DOCKER_VOLUME}}) \
                          ifelse(DOCKER_VOLUMES_FROM, {{none}}, {{}}, --volumes-from {{DOCKER_VOLUMES_FROM}}) \
                          ifelse(MYSQL_PORT, {{}}, {{}}, -p MYSQL_PORT:3306) \
                          -e "{{MYSQL_DATABASE}}=MYSQL_DATABASE" \
                          -e "{{MYSQL_USER}}=MYSQL_USER" \
                          -e "{{MYSQL_PASSWORD}}=MYSQL_PASS" \
                          -e "{{MYSQL_ROOT_PASSWORD}}=MYSQL_ROOT_PASS" \
                          -e "SERVICE_NAME=DNS_SERVICE_NAME" \
                          -e "SERVICE_ID=DNS_SERVICE_ID" \
                           DOCKER_IMAGE mysqld \
                                           --skip-name-resolve \
                                           --basedir=/usr \
                                           --datadir=/var/lib/mysql \
                                           --plugin-dir=/usr/lib/mysql/plugin \
                                           --user=mysql \
                                           --pid-file=/var/run/mysqld/mysqld.pid \
                                           --socket=/var/run/mysqld/mysqld.sock \
                                           --port=3306 \
                                           --log-warnings \
dnl                                        --log-error=/var/log/mysql/error.log \
                                           --console \
dnl                                        Performance tuning options
                                           --join_buffer_size=MYSQL_JOIN_BUFFER_SIZE \
                                           --query_cache_type=MYSQL_QUERY_CACHE_TYPE \
                                           --query_cache_limit=MYSQL_QUERY_CACHE_LIMIT \
                                           --query_cache_size=MYSQL_QUERY_CACHE_SIZE \
                                           --read_rnd_buffer_size=MYSQL_READ_RND_BUFFER_SIZE \
                                           --table_open_cache=MYSQL_TABLE_OPEN_CACHE \
                                           --tmp_table_size=MYSQL_TMP_TABLE_SIZE \
                                           --max_heap_table_size=MYSQL_MAX_HEAP_TABLE_SIZE \
                                           --key_buffer_size=MYSQL_KEY_BUFFER_SIZE \
                                           --max_user_connections=MYSQL_MAX_USER_CONNECTIONS \
                                           --max_connections=MYSQL_MAX_CONNECTIONS \
                                           --general_log=MYSQL_GENERAL_LOG \
                                           --sql_mode='MYSQL_SQL_MODE' \
                                           --explicit_defaults_for_timestamp=MYSQL_EXPLICIT_DEFAULTS_FOR_TIMESTAMP \
                                           --innodb_buffer_pool_size=MYSQL_INNODB_BUFFER_POOL_SIZE \
                                           --innodb_file_per_table=MYSQL_INNODB_FILE_PER_TABLE \
                                           --innodb_flush_log_at_trx_commit=MYSQL_INNODB_FLUSH_LOG_AT_TRX_COMMIT \
                                           --innodb_log_buffer_size=MYSQL_INNODB_LOG_BUFFER_SIZE 

#ExecStartPost=/usr/bin/docker exec DOCKER_NAME rm -f $$INIT_SQL
ExecStartPost=-/usr/bin/etcdctl set /mysql/DOCKER_NAME/machine '%m'
ExecStop=-/usr/bin/docker exec DOCKER_NAME mysqladmin -uroot {{-p}}MYSQL_ROOT_PASS shutdown
ExecStopPost=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
TimeoutStopSec=DOCKER_STOP_TIMEOUT{{s}}
RestartSec=10s
Restart=always


[Install]
WantedBy=multi-user.target

[X-Fleet]
ifelse(FLEET_MACHINE_OF_SERVICE, {{.service}}, {{}}, MachineOf={{FLEET_MACHINE_OF_SERVICE}})
ifelse(FLEET_CONFLICTS_WITH_SERVICE, {{.service}}, {{}}, Conflicts={{FLEET_CONFLICTS_WITH_SERVICE}})
ifelse(FLEET_MACHINE_METADATA, {{}}, {{}}, {{MachineMetadata=FLEET_MACHINE_METADATA}})

