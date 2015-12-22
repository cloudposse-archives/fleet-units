changequote({{,}})dnl
define(SSH_PORT, 22)dnl

[Unit]
Description=Restart the SSH socket upon failure
After=network.target 

[Service]
Type=oneshot
ExecStart=/bin/sh -c '(ncat localhost SSH_PORT < /dev/null |grep ^SSH) || sudo systemctl restart sshd.socket'
RemainAfterExit=no

[Install]
WantedBy=multi-user.target

[X-Fleet]
Global=true
