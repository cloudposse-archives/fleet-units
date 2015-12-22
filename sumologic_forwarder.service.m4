changequote({{,}})dnl
define(SYSLOG_PROTO, udp)dnl
define(SYSLOG_HOST, localhost)dnl
define(SYSLOG_PORT, 514)dnl
define(JOURNALCTL_OUTPUT, json)dnl

[Unit]
Description=Send Journalctl to Sumologic
 
[Service]
TimeoutStartSec=0
ExecStart=/bin/sh -c '/usr/bin/journalctl -f -o JOURNALCTL_OUTPUT | /usr/bin/ncat --SYSLOG_PROTO SYSLOG_HOST SYSLOG_PORT'

Restart=always
RestartSec=5s

[X-Fleet]
Global=true
