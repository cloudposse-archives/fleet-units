changequote({{,}})dnl
define(NTPDATE_SERVERS, 0.coreos.pool.ntp.org 1.coreos.pool.ntp.org 2.coreos.pool.ntp.org 3.coreos.pool.ntp.org)dnl

[Unit]
Description=Set time via NTP using ntpdate
After=network.target 
Conflicts=systemd-timesyncd.service

[Service]
Type=oneshot
ExecStart=/usr/sbin/ntpdate -b -u NTPDATE_SERVERS
# Cannot linger after exit in combination with timers
RemainAfterExit=no

[Install]
WantedBy=multi-user.target

[X-Fleet]
Global=true
