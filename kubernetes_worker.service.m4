changequote({{,}})dnl
define(DOCKER_NAME, jenkins)dnl
define(DOCKER_REGISTRY, gcr.io)dnl
define(DOCKER_TAG, dev)dnl
define(DOCKER_REPOSITORY, google-containers/hyperkube:DOCKER_TAG)dnl
define(DOCKER_IMAGE, DOCKER_REGISTRY/DOCKER_REPOSITORY)dnl
define(DOCKER_STOP_TIMEOUT, 20)dnl
define(DNS_SERVICE_NAME, {{kubernetes}})dnl
define(DNS_SERVICE_ID, {{master}})dnl
define(KUBERNETES_MASTER_HOST, {{master}})dnl
define(KUBERNETES_MASTER_PORT, 8080)dnl

{{#}} Based on https://github.com/GoogleCloudPlatform/kubernetes/blob/master/docs/getting-started-guides/docker.md
{{#}}          https://github.com/GoogleCloudPlatform/kubernetes/blob/master/docs/getting-started-guides/docker-multinode/master.md
{{#}}          https://github.com/GoogleCloudPlatform/kubernetes/blob/master/docs/getting-started-guides/docker-multinode/worker.md#adding-a-kubernetes-worker-node-via-docker

[Unit]
Description=Kubernetes Worker
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

ExecStart=/usr/bin/docker run \
                          --name DOCKER_NAME \
                          --net=host \
                          --rm \
                          -e "SERVICE_8080_NAME=DNS_SERVICE_NAME" \
                          -e "SERVICE_8080_ID=DNS_SERVICE_ID" \
                          --volume /var/run/docker.sock:/var/run/docker.sock \
                          DOCKER_IMAGE \
                          /hyperkube kubelet \
                                  --api_servers=http://KUBERNETES_MASTER_HOST:KUBERNETES_MASTER_PORT \
                                  --enable_server \
                                  --address=0.0.0.0 \
                                  --logtostderr=true \
                                  --hostname_override=%H \
                                  --v=2   

ExecStop=-/usr/bin/docker stop --time=DOCKER_STOP_TIMEOUT DOCKER_NAME
ExecStopPost=-/usr/bin/docker rm DOCKER_NAME
TimeoutStopSec=DOCKER_STOP_TIMEOUT{{s}}

RestartSec=10s
Restart=always

[Install]
WantedBy=multi-user.target

[X-Fleet]
Global=true
