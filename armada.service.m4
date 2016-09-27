changequote({{,}})dnl
define(DOCKER_NAME, something)dnl
define(DOCKER_VOLUME, none)dnl
define(DOCKER_VOLUME_OCTAL_MODE, 1777)dnl
define(DOCKER_VOLUMES_FROM, {{none}})dnl
define(DOCKER_VOLUMES_FROM_SERVICE, {{DOCKER_VOLUMES_FROM}}.service)dnl
define(DOCKER_REGISTRY, {{{{index.docker.io}}}})dnl
define(DOCKER_REPOSITORY, {{cloudposse/armada}})dnl
define(DOCKER_TAG, {{latest}})dnl
define(DOCKER_IMAGE, {{DOCKER_REGISTRY}}/{{DOCKER_REPOSITORY}}:{{DOCKER_TAG}})dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl
define(DOCKER_HOSTNAME, something.vps.ourcloud.local)dnl
define(DOCKER_DNS, ${DNS_SERVER})dnl
define(DOCKER_HOST, )dnl
define(PROXY_SSH_PORT, )dnl
define(GIT_USERS, )dnl
define(GITHUB_USERS, )dnl
define(DNS_SERVICE_NAME, {{{{arada}}}})dnl
define(DNS_SERVICE_ID, {{{{%H}}}})dnl
define(FLEET_MACHINE_OF, )dnl
define(FLEET_MACHINE_OF_SERVICE, {{FLEET_MACHINE_OF}}.service)dnl
define(FLEET_CONFLICTS_WITH, )dnl
define(FLEET_CONFLICTS_WITH_SERVICE, {{FLEET_CONFLICTS_WITH}}.service)dnl
define(FLEET_MACHINE_METADATA, )dnl

[Unit]
Description=Armada PaaS ifelse(DOCKER_VOLUME, {{none}}, {{}}, with volumes from {{DOCKER_VOLUME}})
Requires={{docker.service}}
After={{docker.service}}
Requires=flanneld.service
After=flanneld.service
ifelse(DOCKER_VOLUMES_FROM_SERVICE, {{none.service}}, {{}}, Requires={{DOCKER_VOLUMES_FROM_SERVICE}})
ifelse(DOCKER_VOLUMES_FROM_SERVICE, {{none.service}}, {{}}, After={{DOCKER_VOLUMES_FROM_SERVICE}})
ifelse(DOCKER_VOLUMES_FROM_SERVICE, {{none.service}}, {{}}, PartOf={{DOCKER_VOLUMES_FROM_SERVICE}})

[Service]
User={{core}}
EnvironmentFile=/etc/environment
EnvironmentFile=/etc/env.d/*
TimeoutStartSec=0
ExecStartPre=-{{/usr/bin/docker}} --debug=true pull DOCKER_IMAGE

ifelse(DOCKER_VOLUME, {{none}}, {{}}, ExecStartPre=/usr/bin/sh -c "echo {{DOCKER_VOLUME}} | cut -d: -f1 | xargs mkdir -p -m {{DOCKER_VOLUME_OCTAL_MODE}}")
ExecStartPre=-{{/usr/bin/docker}} stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStartPre=-{{/usr/bin/docker}} rm DOCKER_NAME
ExecStart={{/usr/bin/docker}} run \
                          --rm \
                          --name DOCKER_NAME \
                          --privileged \
                          ifelse(DOCKER_VOLUMES_FROM, {{none}}, {{}}, --volumes-from {{DOCKER_VOLUMES_FROM}}) \
                          -v /var/run/fleet.sock:/var/run/fleet.sock \
                          -v /usr/bin/fleetctl:/usr/bin/fleetctl:ro \
                          ifelse(DOCKER_DNS, {{}}, {{}}, --dns {{DOCKER_DNS}}) \
                          ifelse(DOCKER_HOSTNAME, {{none}}, {{}}, --hostname {{DOCKER_HOSTNAME}}) \
                          ifelse(DOCKER_VOLUME, {{none}}, {{}}, --volume {{DOCKER_VOLUME}}) \
                          -e "{{DOCKER_HOST}}=DOCKER_HOST" \
                          -e "{{GIT_USERS}}=GIT_USERS" \
                          -e "{{GITHUB_USERS}}=GITHUB_USERS" \
                          -e "SERVICE_NAME=DNS_SERVICE_NAME" \
                          -e "SERVICE_ID=DNS_SERVICE_ID" \
                          DOCKER_IMAGE 
ifelse(PROXY_SSH_PORT, {{}}, {{}}, ExecStartPost=/usr/bin/etcdctl set /haproxy/tcp/{{PROXY_SSH_PORT}}/{{DOCKER_NAME}} "{{DOCKER_HOSTNAME}}:22 check port 22 resolvers dns") 

ExecStop=-{{/usr/bin/docker}} stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
TimeoutStopSec=DOCKER_STOP_TIMEOUT{{s}}

RestartSec=10s
Restart=always


[Install]
WantedBy=multi-user.target

[X-Fleet]
ifelse(FLEET_MACHINE_OF_SERVICE, {{.service}}, {{}}, MachineOf={{FLEET_MACHINE_OF_SERVICE}})
ifelse(FLEET_CONFLICTS_WITH_SERVICE, {{.service}}, {{}}, Conflicts={{FLEET_CONFLICTS_WITH_SERVICE}})
ifelse(FLEET_MACHINE_METADATA, {{}}, {{}}, {{MachineMetadata=FLEET_MACHINE_METADATA}})

