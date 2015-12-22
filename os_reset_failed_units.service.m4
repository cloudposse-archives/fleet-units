changequote({{,}})dnl

[Unit]
Description=Reset Failed Units Log
After=network.target 

[Service]
Type=oneshot
RemainAfterExit=no
ExecStart=/usr/bin/sudo systemctl reset-failed

[Install]
WantedBy=multi-user.target

[X-Fleet]
Global=true
