changequote({{,}})dnl
define(VULCAND_NAME, vulcand)dnl
define(VULCAND_SERVICE, {{VULCAND_NAME}}.service)dnl
define(BACKEND_NAME, default)dnl
define(FRONTEND_NAME, %i)dnl
define(VIRTUAL_HOST, localhost)dnl
define(ETCD_HOST, http://${COREOS_PRIVATE_IPV4}:4001)dnl

[Unit]
Description=Announce to Vulcand that VIRTUAL_HOST is available on BACKEND_NAME 
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
ExecStart=/usr/bin/sh -c "until /usr/bin/docker exec VULCAND_NAME /go/bin/vctl --vulcan 'http://localhost:8192' frontend upsert -id FRONTEND_NAME -b BACKEND_NAME -route 'Host(`VIRTUAL_HOST`) && PathRegexp(`.*`)'; do echo 'Failed to assign BACKEND_NAME to FRONTEND_NAME for VIRTUAL_HOST'; sleep 1; done"

# If vulcand is stopped, this command will fail
#ExecStop=-/usr/bin/docker exec VULCAND_NAME /go/bin/vctl --vulcan 'http://localhost:8192' frontend delete -id FRONTEND_NAME -b BACKEND_NAME -route 'Host(`VIRTUAL_HOST`) && PathRegexp(`.*`)'

[Install]
WantedBy=multi-user.target

[X-Fleet]
MachineOf=VULCAND_SERVICE
