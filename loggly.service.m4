changequote({{,}})dnl
define(LOG_FORWARDER_SYSLOG_HOST, logs2.papertrailapp.com)dnl
define(LOG_FORWARDER_SYSLOG_PORT, 24463)dnl
define(LOG_FORWARDER_TIMEOUT, 60)dnl
define(LOG_FORWARDER_CONNECT_TIMEOUT, 5)dnl

[Unit]
Description=Log forwarder

[Service]
ExecStart=/bin/sh -c "echo LOGGLY_API_KEY; journalctl -o json -f | ncat --idle-timeout LOG_FORWARDER_TIMEOUT --wait LOG_FORWARDER_CONNECT_TIMEOUT --ssl LOG_FORWARDER_SYSLOG_HOST LOG_FORWARDER_SYSLOG_PORT"
Restart=on-failure
TimeoutSec=300
RestartSec=10

[Install]
WantedBy=multi-user.target

[X-Fleet]
Global=true
