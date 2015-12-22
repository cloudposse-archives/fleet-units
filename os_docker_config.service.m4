changequote({{,}})dnl
define(DOCKER_CFG, /home/core/.dockercfg)dnl
define(DOCKER_AUTH, not-set)dnl
define(DOCKER_EMAIL, noreply@nohost.com)dnl
define(DOCKER_REGISTRY, index.docker.io)dnl
define(DOCKER_INDEX, index.docker.io)dnl
define({{APPEND}}, {{/bin/sh -c 'echo "$1" >> $2'}})dnl

[Unit]
Description=Manage Docker Config
Before=docker.service
#ConditionPathExists=!DOCKER_CFG

[Service]
Type=oneshot
ExecStartPre=/usr/bin/rm -f DOCKER_CFG
ExecStartPre=/usr/bin/touch DOCKER_CFG
ExecStartPre=/usr/bin/chmod 600 DOCKER_CFG
ExecStartPre=/usr/bin/chown core:core DOCKER_CFG
ExecStart=APPEND({ \\"DOCKER_REGISTRY\\":{\\"auth\\": \\"DOCKER_AUTH\\"{{,}}\\"email\\": \\"DOCKER_EMAIL\\"}{{,}} \\"https://DOCKER_INDEX/v1/\\":{\\"auth\\": \\"DOCKER_AUTH\\"{{,}}\\"email\\": \\"DOCKER_EMAIL\\"} }, DOCKER_CFG)

ExecStop=/usr/bin/rm -f DOCKER_CFG

RemainAfterExit=yes

[Install]
WantedBy=multi-user.target

[X-Fleet]
Global=true
