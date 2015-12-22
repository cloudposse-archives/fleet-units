changequote({{,}})dnl
define(VULCAND_NAME, vulcand)dnl
define(VULCAND_SERVICE, {{VULCAND_NAME}}.service)dnl
define(BACKEND_NAME, default)dnl
define(ETCD_HOST, http://${COREOS_PRIVATE_IPV4}:4001)dnl

[Unit]
Description=Announce to Vulcand to create BACKEND_NAME 
Requires=docker.service
After=docker.service
Requires=etcd2.service
After=etcd2.service
Requires=flanneld.service
After=flanneld.service

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
ExecStart=/usr/bin/sh -c "until /usr/bin/docker exec VULCAND_NAME /go/bin/vctl --vulcan 'http://localhost:8192' backend upsert -id BACKEND_NAME; do echo 'Failed to create BACKEND_NAME'; sleep 1; done"

# If vulcand is stopped, this command will fail
#ExecStop=-/usr/bin/docker exec VULCAND_NAME /go/bin/vctl --vulcan 'http://localhost:8192' backend delete -id BACKEND_NAME

[Install]
WantedBy=multi-user.target

[X-Fleet]
MachineOf=VULCAND_SERVICE
