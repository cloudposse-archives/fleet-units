changequote({{,}})dnl
define(NF_CONNTRACK_MAX, 262144)dnl

[Unit]
Description=Increase the number of connections in nf_conntrack. default is 65536

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStartPre=/usr/bin/sudo /usr/sbin/modprobe nf_conntrack
ExecStart=/usr/bin/sudo sysctl -w net.netfilter.nf_conntrack_max=NF_CONNTRACK_MAX

[X-Fleet]
Global=true
