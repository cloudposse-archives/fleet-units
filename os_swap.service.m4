changequote({{,}})dnl
define(SWAP_SIZE, 512m)dnl
define(SWAP_FILE, /swapfile)dnl

[Unit]
Description=Turn on swap
dnl ConditionPathExists=!SWAP_FILE
Before=docker.service

[Service]
User=root
Type=oneshot
RemainAfterExit=true

ExecStartPre=/usr/bin/fallocate -l SWAP_SIZE SWAP_FILE
ExecStartPre=/usr/bin/chmod 600 SWAP_FILE
ExecStartPre=/usr/sbin/mkswap SWAP_FILE
dnl ExecStartPre=/usr/sbin/losetup -f SWAP_FILE
dnl ExecStart=/usr/bin/sh -c '/sbin/swapon $(/usr/sbin/losetup -j SWAP_FILE | /usr/bin/cut -d : -f 1)'
ExecStart=/sbin/swapon SWAP_FILE
dnl ExecStop=/usr/bin/sh -c '/sbin/swapoff $(/usr/sbin/losetup -j SWAP_FILE | /usr/bin/cut -d : -f 1)'
ExecStop=/sbin/swapoff SWAP_FILE
dnl ExecStopPost=/usr/bin/sh -c '/usr/sbin/losetup -d $(/usr/sbin/losetup -j SWAP_FILE | /usr/bin/cut -d : -f 1)'
ExecStopPost=/usr/bin/rm -f SWAP_FILE

[Install]
WantedBy=local.target

[X-Fleet]
Global=true
