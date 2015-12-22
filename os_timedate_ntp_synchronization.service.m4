changequote({{,}})dnl

[Unit]
Description=Synchronize system clock
After=ntpdate.service
BindTo=ntpdate.service

[Service]
ExecStart=/usr/bin/timedatectl set-ntp true
ExecStartPost=/sbin/hwclock --systohc --utc
RemainAfterExit=yes
Type=oneshot

[X-Fleet]
Global=true
