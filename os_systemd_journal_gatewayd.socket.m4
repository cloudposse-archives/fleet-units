changequote({{,}})dnl

[Unit] 
Description=Journal Gateway Service Socket 
Before=docker.service


[Socket] 
ListenStream=/var/run/journald.sock 
Service=systemd-journal-gatewayd.service 

[Install] 
WantedBy=sockets.target
