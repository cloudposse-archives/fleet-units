changequote({{,}})dnl
define(DEIS_VERSION, 1.4.1)dnl

[Unit]
Description=Install deisctl utility
ConditionPathExists=!/opt/bin/deisctl

[Service]
Type=oneshot
ExecStart=/usr/bin/sh -c 'curl -sSL --retry 5 --retry-delay 2 http://deis.io/deisctl/install.sh | sh -s DEIS_VERSION'

[X-Fleet]
Global=true
