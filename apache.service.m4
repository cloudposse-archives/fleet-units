changequote({{,}})dnl
define(DATA_VOL_NAME, )dnl
define(DATA_VOL_SERVICE, {{DATA_VOL_NAME}}.service)dnl
define(DB_HOST, )dnl
define(DB_USER, )dnl
define(DB_PASS, )dnl
define(DB_NAME, )dnl
define(HTTP_HOST, )dnl
define(APACHE_PORT, )dnl
define(APACHE_LOGS, )dnl
dnl Apache MPM Worker Settings
dnl The maximum number of active child processes is determined by the MaxClients directive divided by the ThreadsPerChild directive.
define(APACHE_WORKER_START_SERVERS,)dnl  2
define(APACHE_WORKER_MIN_SPARE_THREADS,)dnl 2 
define(APACHE_WORKER_MAX_SPARE_THREADS,)dnl 10
define(APACHE_WORKER_THREAD_LIMIT,)dnl 64; must be >= ThreadsPerChild
define(APACHE_WORKER_THREADS_PER_CHILD,)dnl 25; (aka "Server Threads")
define(APACHE_WORKER_MAX_REQUEST_WORKERS,)dnl 50;  MaxRequestWorkers must be at least as large as the number of threads in a single server.
define(APACHE_WORKER_MAX_CONNECTIONS_PER_CHILD, )dnl 0
dnl Apache MPM Event Settings
define(APACHE_EVENT_START_SERVERS, )dnl 2
define(APACHE_EVENT_MIN_SPARE_THREADS, )dnl 25
define(APACHE_EVENT_MAX_SPARE_THREADS, )dnl 75
define(APACHE_EVENT_THREAD_LIMIT, )dnl 64
define(APACHE_EVENT_THREADS_PER_CHILD, )dnl 25
define(APACHE_EVENT_MAX_REQUEST_WORKERS, )dnl 150; MaxRequestWorkers (150) must be an integer multiple of ThreadsPerChild (25)
define(APACHE_EVENT_MAX_CONNECTIONS_PER_CHILD, )dnl 0
dnl Apache MPM Prefork Settings
define(APACHE_PREFORK_START_SERVERS, )dnl 1
define(APACHE_PREFORK_MIN_SPARE_SERVERS, )dnl 1
define(APACHE_PREFORK_MAX_SPARE_SERVERS, )dnl 5
define(APACHE_PREFORK_MAX_REQUEST_WORKERS, )dnl 2
define(APACHE_PREFORK_MAX_CONNECTIONS_PER_CHILD, )dnl 0
dnl PHP FPM Settings (if applicable)
define(PHP_FPM_PM, )dnl
define(PHP_FPM_MAX_CHILDREN, )dnl
define(PHP_FPM_START_SERVERS, )dnl
define(PHP_FPM_SPARE_SERVERS, )dnl
define(PHP_FPM_MAX_SPARE_SERVERS, )dnl
define(PHP_FPM_PROCESS_IDLE_TIMEOUT, )dnl
define(PHP_FPM_MAX_REQUESTS, )dnl
dnl
define(DOCKER_NAME, apache)dnl
define(DOCKER_REGISTRY, index.docker.io)dnl
define(DOCKER_REPOSITORY, cloudposse/apache)dnl
define(DOCKER_TAG, latest)dnl
define(DOCKER_IMAGE, {{DOCKER_REGISTRY}}/{{DOCKER_REPOSITORY}}:{{DOCKER_TAG}})dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl
define(DOCKER_VOLUME, )dnl
define(DOCKER_LOGS, )dnl
define(DOCKER_DNS, ${DNS_SERVER})dnl
define(DOCKER_DNS_SEARCH, )dnl
define(DOCKER_MEMORY, 500m)dnl
define(DOCKER_CPU_SHARES, 100)dnl
define(DNS_SERVICE_NAME, apache)dnl
define(DNS_SERVICE_ID, %H)dnl
define(FLEET_CONFLICTS, %p@*)dnl


[Unit]
Description=Apache Web Server
Requires=docker.service
After=docker.service
Requires=flanneld.service
After=flanneld.service
ifelse(DATA_VOL_SERVICE, {{.service}}, {{}}, After=DATA_VOL_SERVICE)
ifelse(DATA_VOL_SERVICE, {{.service}}, {{}}, Requires=DATA_VOL_SERVICE)
dnl Seems to cause problems when recreating the data-vol service
ifelse(DATA_VOL_SERVICE, {{.service}}, {{}}, BindTo=DATA_VOL_SERVICE)
ifelse(DATA_VOL_SERVICE, {{.service}}, {{}}, RequiredBy=DATA_VOL_SERVICE)

[Service]
User=core
EnvironmentFile=/etc/environment
EnvironmentFile=/etc/env.d/*
TimeoutStartSec=0
ExecStartPre=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStartPre=-/usr/bin/docker rm DOCKER_NAME
ExecStartPre=-/usr/bin/docker --debug=true pull DOCKER_IMAGE
ExecStart=/usr/bin/docker run --name DOCKER_NAME \
                              --rm \
                              ifelse(DOCKER_MEMORY, {{}}, {{}}, --memory={{DOCKER_MEMORY}}) \
                              ifelse(DOCKER_CPU_SHARES, {{}}, {{}}, --cpu-shares={{DOCKER_CPU_SHARES}}) \
                              ifelse(DOCKER_DNS, {{}}, {{}}, --dns={{DOCKER_DNS}}) \
                              ifelse(DOCKER_DNS_SEARCH, {{}}, {{}}, --dns-search={{DOCKER_DNS_SEARCH}}) \
                              ifelse(DOCKER_VOLUME, {{}}, {{}}, --volume {{DOCKER_VOLUME}}) \
                              ifelse(DOCKER_LOGS, {{}}, {{}}, --volume {{DOCKER_LOGS}}) \
                              ifelse(APACHE_LOGS, {{}}, {{}}, --volume {{APACHE_LOGS}}) \
                              ifelse(APACHE_PORT, {{}}, {{}}, -p {{APACHE_PORT}}:80) \
dnl                           Apache MPM Settings
                              ifelse(APACHE_WORKER_START_SERVERS, {{}}, {{}}, -e "{{{{APACHE_WORKER_START_SERVERS}}}}={{APACHE_WORKER_START_SERVERS}}") \
                              ifelse(APACHE_WORKER_MIN_SPARE_THREADS, {{}}, {{}}, -e "{{{{APACHE_WORKER_MIN_SPARE_THREADS}}}}={{APACHE_WORKER_MIN_SPARE_THREADS}}") \
                              ifelse(APACHE_WORKER_MAX_SPARE_THREADS, {{}}, {{}}, -e "{{{{APACHE_WORKER_MAX_SPARE_THREADS}}}}={{APACHE_WORKER_MAX_SPARE_THREADS}}") \
                              ifelse(APACHE_WORKER_THREAD_LIMIT, {{}}, {{}}, -e "{{{{APACHE_WORKER_THREAD_LIMIT}}}}={{APACHE_WORKER_THREAD_LIMIT}}") \
                              ifelse(APACHE_WORKER_THREADS_PER_CHILD, {{}}, {{}}, -e "{{{{APACHE_WORKER_THREADS_PER_CHILD}}}}={{APACHE_WORKER_THREADS_PER_CHILD}}") \
                              ifelse(APACHE_WORKER_MAX_REQUEST_WORKERS, {{}}, {{}}, -e "{{{{APACHE_WORKER_MAX_REQUEST_WORKERS}}}}={{APACHE_WORKER_MAX_REQUEST_WORKERS}}") \
                              ifelse(APACHE_WORKER_MAX_CONNECTIONS_PER_CHILD, {{}}, {{}}, -e "{{{{APACHE_WORKER_MAX_CONNECTIONS_PER_CHILD}}}}={{APACHE_WORKER_MAX_CONNECTIONS_PER_CHILD}}") \
dnl                           Apache MPM Event Settings
                              ifelse(APACHE_EVENT_START_SERVERS, {{}}, {{}}, -e "{{{{APACHE_EVENT_START_SERVERS}}}}={{APACHE_EVENT_START_SERVERS}}") \
                              ifelse(APACHE_EVENT_MIN_SPARE_THREADS, {{}}, {{}}, -e "{{{{APACHE_EVENT_MIN_SPARE_THREADS}}}}={{APACHE_EVENT_MIN_SPARE_THREADS}}") \
                              ifelse(APACHE_EVENT_MAX_SPARE_THREADS, {{}}, {{}}, -e "{{{{APACHE_EVENT_MAX_SPARE_THREADS}}}}={{APACHE_EVENT_MAX_SPARE_THREADS}}") \
                              ifelse(APACHE_EVENT_THREAD_LIMIT, {{}}, {{}}, -e "{{{{APACHE_EVENT_THREAD_LIMIT}}}}={{APACHE_EVENT_THREAD_LIMIT}}") \
                              ifelse(APACHE_EVENT_THREADS_PER_CHILD, {{}}, {{}}, -e "{{{{APACHE_EVENT_THREADS_PER_CHILD}}}}={{APACHE_EVENT_THREADS_PER_CHILD}}") \
                              ifelse(APACHE_EVENT_MAX_REQUEST_WORKERS, {{}}, {{}}, -e "{{{{APACHE_EVENT_MAX_REQUEST_WORKERS}}}}={{APACHE_EVENT_MAX_REQUEST_WORKERS}}") \
                              ifelse(APACHE_EVENT_MAX_CONNECTIONS_PER_CHILD, {{}}, {{}}, -e "{{{{APACHE_EVENT_MAX_CONNECTIONS_PER_CHILD}}}}={{APACHE_EVENT_MAX_CONNECTIONS_PER_CHILD}}") \
dnl                           Apache MPM Prefork Settings
                              ifelse(APACHE_PREFORK_START_SERVERS, {{}}, {{}}, -e "{{{{APACHE_PREFORK_START_SERVERS}}}}={{APACHE_PREFORK_START_SERVERS}}") \
                              ifelse(APACHE_PREFORK_MIN_SPARE_SERVERS, {{}}, {{}}, -e "{{{{APACHE_PREFORK_MIN_SPARE_SERVERS}}}}={{APACHE_PREFORK_MIN_SPARE_SERVERS}}") \
                              ifelse(APACHE_PREFORK_MAX_SPARE_SERVERS, {{}}, {{}}, -e "{{{{APACHE_PREFORK_MAX_SPARE_SERVERS}}}}={{APACHE_PREFORK_MAX_SPARE_SERVERS}}") \
                              ifelse(APACHE_PREFORK_MAX_REQUEST_WORKERS, {{}}, {{}}, -e "{{{{APACHE_PREFORK_MAX_REQUEST_WORKERS}}}}={{APACHE_PREFORK_MAX_REQUEST_WORKERS}}") \
                              ifelse(APACHE_PREFORK_MAX_CONNECTIONS_PER_CHILD, {{}}, {{}}, -e "{{{{APACHE_PREFORK_MAX_CONNECTIONS_PER_CHILD}}}}={{APACHE_PREFORK_MAX_CONNECTIONS_PER_CHILD}}") \
dnl                           PHP FPM Settings
                              ifelse(PHP_FPM_PM,  {{}}, {{}}, -e "{{{{PHP_FPM_PM}}}}={{PHP_FPM_PM}}") \
                              ifelse(PHP_FPM_MAX_CHILDREN, {{}}, {{}}, -e "{{{{PHP_FPM_MAX_CHILDREN}}}}={{PHP_FPM_MAX_CHILDREN}}") \
                              ifelse(PHP_FPM_START_SERVERS, {{}}, {{}}, -e "{{{{PHP_FPM_START_SERVERS}}}}={{PHP_FPM_START_SERVERS}}") \
                              ifelse(PHP_FPM_SPARE_SERVERS, {{}}, {{}}, -e "{{{{PHP_FPM_SPARE_SERVERS}}}}={{PHP_FPM_SPARE_SERVERS}}") \
                              ifelse(PHP_FPM_MAX_SPARE_SERVERS, {{}}, {{}}, -e "{{{{PHP_FPM_MAX_SPARE_SERVERS}}}}={{PHP_FPM_MAX_SPARE_SERVERS}}") \
                              ifelse(PHP_FPM_PROCESS_IDLE_TIMEOUT, {{}}, {{}}, -e "{{{{PHP_FPM_MAX_SPARE_SERVERS}}}}={{PHP_FPM_MAX_SPARE_SERVERS}}") \
                              ifelse(PHP_FPM_MAX_REQUESTS, {{}}, {{}}, -e "{{{{PHP_FPM_MAX_REQUESTS}}}}={{PHP_FPM_MAX_REQUESTS}}") \
dnl                           HTTP Env
                              ifelse(HTTP_HOST, {{}}, {{}}, -e "{{{{HTTP_HOST}}}}={{HTTP_HOST}}") \
              
dnl                           Everything else
                              ifelse(DATA_VOL_NAME, {{}}, {{}}, --volumes-from {{DATA_VOL_NAME}}) \
                              ifelse(DB_USER, {{}}, {{}}, -e "{{{{DB_USER}}}}={{DB_USER}}") \
                              ifelse(DB_PASS, {{}}, {{}}, -e "{{{{DB_PASS}}}}={{DB_PASS}}") \
                              ifelse(DB_HOST, {{}}, {{}}, -e "{{{{DB_HOST}}}}={{DB_HOST}}") \
                              ifelse(DB_NAME, {{}}, {{}}, -e "{{{{DB_NAME}}}}={{DB_NAME}}") \
                              -e "SERVICE_NAME=DNS_SERVICE_NAME" \
                              -e "SERVICE_ID=DNS_SERVICE_ID" \
                              DOCKER_IMAGE

ExecStop=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStopPost=-/usr/bin/docker rm DOCKER_NAME
TimeoutStopSec=DOCKER_STOP_TIMEOUT{{s}}

Restart=always
RestartSec=10s

[Install]
WantedBy=multi-user.target

[X-Fleet]
ifelse(DATA_VOL_SERVICE, {{.service}}, {{}}, MachineOf=DATA_VOL_SERVICE)
ifelse(FLEET_CONFLICTS, {{}}, {{}}, Conflicts=FLEET_CONFLICTS)

