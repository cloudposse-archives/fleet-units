changequote({{,}})dnl
define(ETCD_HOST, ${COREOS_PRIVATE_IPV4}:4001)dnl

[Unit]
Description=etcd debugging service

[Service]
EnvironmentFile=/etc/environment

ExecStartPre=/usr/bin/curl -sSL -o /opt/bin/jq http://stedolan.github.io/jq/download/linux64/jq
ExecStartPre=/usr/bin/chmod +x /opt/bin/jq
ExecStart=/usr/bin/bash -c "while true; do curl -sL http://ETCD_HOST/v2/stats/leader | /opt/bin/jq . ; sleep 1 ; done"

[X-Fleet]
Global=true
