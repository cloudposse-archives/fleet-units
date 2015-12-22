changequote({{,}})dnl
define(SYSTEMCTL_NAME, )dnl
define(SYSTEMCTL_SERVICE, {{SYSTEMCTL_NAME}}.service)dnl
define(SYSTEMCTL_ACTION, restart)dnl
define(FLEET_GLOBAL_SERVICE, true)dnl

[Unit]
Description=Perform systemctl SYSTEMCTL_ACTION SYSTEMCTL_SERVICE
Requires=SYSTEMCTL_SERVICE

[Service]
Type=oneshot
EnvironmentFile=/etc/environment
EnvironmentFile=/etc/env.d/*

ExecStart=/usr/bin/systemctl SYSTEMCTL_ACTION SYSTEMCTL_SERVICE

[X-Fleet]
# This unit will always be colocated with the service
ifelse(FLEET_GLOBAL_SERVICE, {{true}}, {{}}, MachineOf=SYSTEMCTL_SERVICE)
ifelse(FLEET_GLOBAL_SERVICE, {{true}}, {{Global=FLEET_GLOBAL_SERVICE}}, {{}})
