changequote({{,}})dnl
define(MOUNT_DEVICE, /dev/sdb)dnl
define(MOUNT_POINT, /media/sdb)dnl
define(MOUNT_OCTAL_MODE, 1777)dnl

[Unit]
Description=Mount filesystem on MOUNT_DEVICE to MOUNT_POINT
Before=docker.service

[Service]
Type=oneshot
RemainAfterExit=true

ExecStartPre=-/usr/bin/mkdir -p MOUNT_POINT
ExecStartPre=/usr/sbin/fsck -p MOUNT_DEVICE
ExecStart=/usr/bin/mount MOUNT_DEVICE MOUNT_POINT
ExecStartPost=/usr/bin/chmod MOUNT_OCTAL_MODE MOUNT_POINT
ExecStop=/usr/bin/unmount MOUNT_POINT
ExecStopPost=/usr/bin/rmdir MOUNT_POINT

[Install]
WantedBy=local.target

[X-Fleet]
Global=true
