changequote({{,}})dnl
define(FLEET_GLOBAL_SERVICE, true)dnl
define(DOCKER_DNS, ${DNS_SERVER})dnl
define(DOCKER_IMAGE, {{mailgun/vulcand:v0.8.0-beta.3}})dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl
define(DOCKER_NAME, {{vulcand}})dnl
define(DOCKER_MEMORY, 10g)dnl
define(DOCKER_CPU_SHARES, 200)dnl
define(VULCAND_PORT, 81)dnl
define(ETCD_HOST, ${COREOS_PRIVATE_IPV4}:4001)dnl
  
[Unit]
Description=Vulcan HTTP Proxy
Requires=docker.service
After=docker.service
Requires=etcd2.service
After=etcd2.service
Requires=flanneld.service
After=flanneld.service

[Service]
User=core
TimeoutStartSec=0
EnvironmentFile=/etc/environment
EnvironmentFile=/etc/env.d/*
ExecStartPre=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStartPre=-/usr/bin/docker rm DOCKER_NAME
ExecStartPre=-/usr/bin/docker --debug=true pull DOCKER_IMAGE
ExecStart=/usr/bin/docker run \
                          --dns DOCKER_DNS \
                          --rm \
                          --name DOCKER_NAME \
                          ifelse(DOCKER_MEMORY, {{}}, {{}}, --memory={{DOCKER_MEMORY}}) \
                          ifelse(DOCKER_CPU_SHARES, {{}}, {{}}, --cpu-shares={{DOCKER_CPU_SHARES}}) \
                          -e "SERVICE_NAME=DNS_SERVICE_NAME" \
                          -e "SERVICE_ID=DNS_SERVICE_ID" \
                          -p VULCAND_PORT:80 \
                          DOCKER_IMAGE \
                          /go/bin/vulcand -apiInterface=0.0.0.0 -interface=0.0.0.0 -etcd=http://ETCD_HOST -port=80 -apiPort=8192
ExecStop=/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
TimeoutStopSec=DOCKER_STOP_TIMEOUT{{s}}
RestartSec=5s
Restart=always

[X-Fleet]
Global=FLEET_GLOBAL_SERVICE
