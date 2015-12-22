changequote({{,}})dnl
define(TIMEZONE, UTC)dnl

[Unit]
Description=Set the timezone

[Service]
ExecStart=/usr/bin/timedatectl set-timezone TIMEZONE
RemainAfterExit=yes
Type=oneshot

