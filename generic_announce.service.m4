changequote({{,}})dnl
define(BACKEND_NAME, generic)dnl
define(BACKEND_PORT, 44444)dnl
define(BACKEND_SERVICE, {{BACKEND_NAME.service}})dnl
define(TTL, 60)dnl
define(SLEEP, 45)dnl

[Unit]
Description=Generic Announce Service 
Requires=etcd2.service
After=etcd2.service
Requires=docker.service
After=docker.service
Requires=BACKEND_SERVICE
After=BACKEND_SERVICE
BindsTo=BACKEND_SERVICE
RequiredBy=BACKEND_SERVICE

[Service]
EnvironmentFile=/etc/environment
EnvironmentFile=/etc/env.d/*

# Add a server to the cluster
ExecStart=/bin/sh -c "while true; do /usr/bin/etcdctl set /BACKEND_NAME/clients/%m \"${COREOS_PRIVATE_IPV4}:BACKEND_PORT\" --ttl TTL; sleep SLEEP; done"

# Deregister the service
ExecStop=-/usr/bin/etcdctl rm /BACKEND_NAME/clients/%m

[X-Fleet]
# This unit will always be colocated with the service
MachineOf=BACKEND_SERVICE
