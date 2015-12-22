changequote({{,}})dnl
define(SYSTEMD_UNIT,  /run/systemd/system/etcd2.service.d/20-cloudinit.conf)dnl
define(ENV_FILE, /etc/env.d/env.sh)dnl

[Unit]
Description=Export Environemnt from Systemd Service
Requires=docker.service
After=docker.service
Requires={{etcd2.service}}
After={{etcd2.service}}
Requires=flanneld.service
After=flanneld.service

[Service]
Type=oneshot
RemainAfterExit=true
User=core
TimeoutStartSec=0
EnvironmentFile=/etc/environment
EnvironmentFile=/etc/env.d/*
ExecStart=/bin/sh -c 'grep ^Environment SYSTEMD_UNIT |cut -d= -f2,3 |xargs -0 echo |xargs -n1 echo | sudo tee ENV_FILE'

[X-Fleet]
Global=true
