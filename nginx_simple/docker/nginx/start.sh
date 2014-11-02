#!/bin/bash

set -eu

if [ $(whoami) != "root" ]; then
    echo root only >&2
    exit 1
fi

share_dir=/opt/docker
mkdir -p ${share_dir}

# data container
container_name=data1
mkdir -p ${share_dir}/${container_name}
rm -rf ${share_dir}/${container_name}/*
mkdir -p ${share_dir}/${container_name}/var/log/{nginx,monit}
echo -n "DATA CONTAINER: "
docker -H="0.0.0.0:5422" run -i -d -t -P \
    --cidfile=$(pwd)/${container_name}.cid \
    --name ${container_name} \
    -v ${share_dir}/${container_name}/var/log/nginx:/var/log/nginx \
    -v ${share_dir}/${container_name}/var/log/monit:/var/log/monit \
    -v /etc/localtime:/etc/localtime:ro \
    ubuntu:14.04 \
    /bin/bash

# app1
container_name=app1
echo -n "APP CONTAINER: "
docker -H="0.0.0.0:5422" run -i -d -t \
    --cidfile=$(pwd)/${container_name}.cid \
    -p 12812:2812 \
    -p 10080:80 \
    --name ${container_name} \
    --volumes-from data1 \
    -v /etc/localtime:/etc/localtime:ro \
    sgykfjsm/ubuntu_nginx
