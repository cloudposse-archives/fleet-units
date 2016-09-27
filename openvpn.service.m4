changequote({{,}})dnl
define(DOCKER_NAME, openvpn)dnl
define(DOCKER_REGISTRY, index.docker.io)dnl
define(DOCKER_TAG, latest)dnl
define(DOCKER_REPOSITORY, kylemanna/openvpn:DOCKER_TAG)dnl
define(DOCKER_IMAGE, DOCKER_REGISTRY/DOCKER_REPOSITORY)dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl
define(DOCKER_DNS, ${DNS_SERVER})dnl
define(DOCKER_HOSTNAME, vpn.ourcloud.local)dnl
define(DOCKER_VOLUME, /tmp/test:/etc/openvpn)dnl
define(OPENVPN_PORT, )dnl
define(OPENVPN_DEBUG, 1)dnl
define(DNS_SERVICE_NAME, jenkins)dnl
define(DNS_SERVICE_ID, %H)dnl
define(FLEET_GLOBAL_SERVICE, {{false}})dnl

[Unit]
Description=OpenVPN on DOCKER_HOSTNAME
Requires=docker.service
After=docker.service
Requires=flanneld.service
After=flanneld.service


[Service]
User=core
EnvironmentFile=/etc/environment
EnvironmentFile=/etc/env.d/*
TimeoutStartSec=0
ExecStartPre=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStartPre=-/usr/bin/docker rm DOCKER_NAME
ExecStartPre=-/usr/bin/docker --debug=true pull DOCKER_IMAGE

{{#}} HOWTO: 
{{#}}   Initialize configuration
{{#}}     `docker run --volume DOCKER_VOLUME --rm DOCKER_IMAGE ovpn_genconfig -u udp://DOCKER_HOSTNAME`
{{#}}     `docker run --volume DOCKER_VOLUME --rm -it DOCKER_IMAGE ovpn_initpki nopass`
{{#}}
{{#}}   Generate a client certificate
{{#}}     `docker run --volume DOCKER_VOLUME --rm -it DOCKER_IMAGE easyrsa build-client-full OPENVPN_CLIENT_NAME nopass`
{{#}}
{{#}}   Retrieve the client configuration with embedded certificates
{{#}}     `docker run --volume DOCKER_VOLUME --rm -it DOCKER_IMAGE ovpn_getclient OPENVPN_CLIENT_NAME nopass`
{{#}}
{{#}}   Revoke the client
{{#}}     `docker run --volume DOCKER_VOLUME --rm -it DOCKER_IMAGE ovpn_getclient OPENVPN_CLIENT_NAME nopass`
{{#}}  
{{#}}   Delete the client certificates `rm $(echo DOCKER_VOLUME|cut -d: -f1)/pki/{reqs,issued,private}/OPENVPN_CLIENT_NAME.*` 
{{#}}

ExecStartPre=/usr/bin/sudo /bin/bash -c "sed -r -i 's:(^push dhcp-option DNS) .*$:\\1 DOCKER_DNS:g' $(echo DOCKER_VOLUME|cut -d':' -f1)/openvpn.conf"
ExecStartPre=/usr/bin/sudo /bin/bash -c "sed -r -i \"s:(^push route .*net_gateway).*$:push route $(hostname) 255.255.255.255 net_gateway:g\" $(echo DOCKER_VOLUME|cut -d':' -f1)/openvpn.conf"
ExecStart=/usr/bin/docker run \
                          --name DOCKER_NAME \
                          --rm \
                          --volume DOCKER_VOLUME \
                          --cap-add=NET_ADMIN \
                          ifelse(DOCKER_DNS, {{}}, {{}}, --dns {{DOCKER_DNS}}) \
                          ifelse(DOCKER_HOSTNAME, {{none}}, {{}}, --hostname {{DOCKER_HOSTNAME}}) \
                          ifelse(OPENVPN_PORT, {{}}, {{}}, -p {{OPENVPN_PORT}}:1194/udp) \
                          ifelse(OPENVPN_DEBUG, {{0}}, {{}}, -e "{{{{OPENVPN_DEBUG}}}}=OPENVPN_DEBUG") \
                          -e "SERVICE_NAME=DNS_SERVICE_NAME" \
                          -e "SERVICE_ID=DNS_SERVICE_ID" \
                          DOCKER_IMAGE 

ExecStop=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStopPost=-/usr/bin/docker rm DOCKER_NAME
TimeoutStopSec=DOCKER_STOP_TIMEOUT{{s}}

RestartSec=10s
Restart=always

[Install]
WantedBy=multi-user.target

[X-Fleet]
Global=FLEET_GLOBAL_SERVICE
