changequote({{,}})dnl
define(IPTABLE_RULES, /var/lib/iptables/rules-save)dnl
define({{APPEND}}, {{/bin/sh -c 'echo "$1" >> $2'}})dnl

[Unit]
Description=Manage IPTABLES
After=network.target 
After=nss-lookup.target
Before=docker.service
Conflicts=iptables-restore.service
ConditionPathExists=!IPTABLE_RULES

[Service]
Type=oneshot
ExecStartPre=/usr/bin/rm -f IPTABLE_RULES
ExecStartPre=APPEND(*filter, IPTABLE_RULES)
ExecStartPre=APPEND(:INPUT DROP [0:0], IPTABLE_RULES)
ExecStartPre=APPEND(:FORWARD DROP [0:0], IPTABLE_RULES)
ExecStartPre=APPEND(:OUTPUT ACCEPT [0:0], IPTABLE_RULES)
ExecStartPre=APPEND(-A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT, IPTABLE_RULES)
ExecStartPre=APPEND(-A INPUT -i lo -j ACCEPT, IPTABLE_RULES)
ExecStartPre=APPEND(-A INPUT -i eth1 -j ACCEPT, IPTABLE_RULES)
ExecStartPre=APPEND(-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT, IPTABLE_RULES)
ExecStartPre=APPEND(-A INPUT -p tcp -m tcp --dport 22 -j ACCEPT, IPTABLE_RULES)
ExecStartPre=APPEND(-A INPUT -p tcp -m tcp --dport 80 -j ACCEPT, IPTABLE_RULES)
ExecStartPre=APPEND(-A INPUT -p tcp -m tcp --dport 443 -j ACCEPT, IPTABLE_RULES)
ExecStartPre=APPEND(-A INPUT -p icmp -m icmp --icmp-type 0 -j ACCEPT, IPTABLE_RULES)
ExecStartPre=APPEND(-A INPUT -p icmp -m icmp --icmp-type 3 -j ACCEPT, IPTABLE_RULES)
ExecStartPre=APPEND(-A INPUT -p icmp -m icmp --icmp-type 11 -j ACCEPT, IPTABLE_RULES)
ExecStartPre=APPEND(COMMIT, IPTABLE_RULES)
ExecStart=/usr/sbin/iptables-restore IPTABLE_RULES

ExecReload=/usr/sbin/iptables-restore IPTABLE_RULES

ExecStop=/usr/bin/rm -f IPTABLE_RULES
ExecStop=APPEND(*filter, IPTABLE_RULES)
ExecStop=APPEND(:INPUT ACCEPT [0:0], IPTABLE_RULES)
ExecStop=APPEND(:FORWARD ACCEPT [0:0], IPTABLE_RULES)
ExecStop=APPEND(:OUTPUT ACCEPT [0:0], IPTABLE_RULES)
ExecStop=APPEND(COMMIT, IPTABLE_RULES)
ExecStop=/usr/sbin/iptables-restore IPTABLE_RULES

RemainAfterExit=yes

[Install]
WantedBy=multi-user.target

[X-Fleet]
Global=true
