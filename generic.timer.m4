changequote({{,}})dnl
define(TIMER_NAME, %n)dnl
define(TIMER_SERVICE, {{TIMER_NAME}}.service)dnl
define(TIMER_CALENDAR, *:*:00)dnl
define(FLEET_GLOBAL_SERVICE, {{false}})dnl
define(FLEET_MACHINE_METADATA, )dnl

[Unit]
Description=Periodically trigger TIMER_NAME @ TIMER_CALENDAR
dnl Requires=TIMER_SERVICE
dnl After=TIMER_SERVICE

# http://www.freedesktop.org/software/systemd/man/systemd.time.html#Calendar%20Events
# The special expressions "minutely", "hourly", "daily", "monthly", "weekly", "yearly", "quarterly", "semiannually" may be used as calendar events 
#  which refer to "*-*-* *:*:00", "*-*-* *:00:00", "*-*-* 00:00:00", "*-*-01 00:00:00", "Mon *-*-* 00:00:00", "*-01-01 00:00:00", "*-01,04,07,10-01 00:00:0" and "*-01,07-01 00:00:00" respectively.

[Timer]
OnBootSec=15m
OnUnitActiveSec=10m
OnCalendar=TIMER_CALENDAR
AccuracySec=5m
Persistent=true     

[Install]
WantedBy=timers.target
WantedBy=TIMER_SERVICE

[X-Fleet]
ifelse(FLEET_GLOBAL_SERVICE, {{true}}, {{}}, {{MachineOf=TIMER_SERVICE}})
ifelse(FLEET_GLOBAL_SERVICE, {{true}}, {{{{Global=true}}}}, {{}})
ifelse(FLEET_MACHINE_METADATA, {{}}, {{}}, {{MachineMetadata=FLEET_MACHINE_METADATA}})

