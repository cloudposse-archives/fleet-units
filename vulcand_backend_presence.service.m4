changequote({{,}})dnl
define(BACKEND_NAME, default)dnl
define(BACKEND_ID, unset)dnl
define(BACKEND_URL, localhost)dnl
define(VULCAND_NAME, vulcand)dnl
define(VULCAND_SERVICE, {{VULCAND_NAME}}.service)dnl

[Unit]
Description=Announce the presence of BACKEND_URL on BACKEND_NAME to Vulcand
Requires=docker.service
After=docker.service
Requires=flanneld.service
After=flanneld.service
After=etcd2.service
Requires=etcd2.service

After=VULCAND_SERVICE
Requires=VULCAND_SERVICE
BindTo=VULCAND_SERVICE

[Service]
TimeoutStartSec=0
User=core
EnvironmentFile=/etc/environment
EnvironmentFile=/etc/env.d/*
Type=oneshot
RemainAfterExit=yes

# Upsert backend after the service has been started
ExecStart=/usr/bin/sh -c "until /usr/bin/docker exec VULCAND_NAME /go/bin/vctl --vulcan 'http://localhost:8192' server upsert -b BACKEND_NAME -id BACKEND_ID -url BACKEND_URL; do echo 'Failed to assign BACKEND_ID to BACKEND_NAME at BACKEND_URL.'; sleep 1; done"

# If vulcand is stopped, this command will fail
#ExecStop=-/usr/bin/docker exec VULCAND_NAME /go/bin/vctl --vulcan 'http://localhost:8192' server rm -b BACKEND_NAME -id BACKEND_ID

[Install]
WantedBy=multi-user.target

[X-Fleet]
MachineOf=VULCAND_SERVICE
