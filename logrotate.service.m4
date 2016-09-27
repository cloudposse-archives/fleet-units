changequote({{,}})dnl
define(FLEET_GLOBAL_SERVICE, false)dnl
define(DOCKER_IMAGE, cloudposse/logrotate:latest)dnl
define(DOCKER_VOLUME,)dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl
define(DOCKER_NAME, logrotate)dnl
define(LOGROTATE_OPTIONS, )dnl
define(LOGROTATE_PATHS, /var/log/*.log)dnl
define(LOGROTATE_STATE_VOLUME, /vol/replicated/root/%n:/var/lib/)dnl
 
[Unit]
Description=Logrotate Service for LOGROTATE_PATHS
Requires=docker.service
After=docker.service
Requires=flanneld.service
After=flanneld.service


[Service]
User=core
Type=oneshot
TimeoutStartSec=0
RemainAfterExit=no
EnvironmentFile=/etc/environment
EnvironmentFile=/etc/env.d/*
ExecStartPre=-/usr/bin/docker --debug=true pull DOCKER_IMAGE
ExecStart=/usr/bin/docker run \
                          ifelse(DOCKER_VOLUME, {{}}, {{}}, --volume {{DOCKER_VOLUME}}) \
                          ifelse(LOGROTATE_STATE_VOLUME, {{}}, {{}}, --volume {{LOGROTATE_STATE_VOLUME}}) \
                          --rm \
                          ifelse(LOGROTATE_PATHS, {{}}, {{}}, -e "{{{{LOGROTATE_PATHS}}}}={{LOGROTATE_PATHS}}") \
                          ifelse(LOGROTATE_OPTIONS, {{}}, {{}}, -e "{{{{LOGROTATE_OPTIONS}}}}={{LOGROTATE_OPTIONS}}") \
                          DOCKER_IMAGE
TimeoutStopSec=DOCKER_STOP_TIMEOUT{{s}}

[X-Fleet]
Global=FLEET_GLOBAL_SERVICE
