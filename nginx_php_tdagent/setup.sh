#!/bin/bash

set -eu

export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
locale-gen en_US.UTF-8
dpkg-reconfigure locales

apt-get -qq -y update && apt-get -qq -y upgrade
apt-get -qq -y install git gcc mercurial ntp

chown -R vagrant:vagrant /home/vagrant/.

curl -sSL https://get.docker.com/ubuntu/ | sh
curl --silent https://raw.githubusercontent.com/docker/docker/master/contrib/completion/bash/docker > /etc/bash_completion.d/docker
source /etc/bash_completion.d/docker

echo source /etc/bash_completion.d/docker >> /home/vagrant/.bash_profile
echo 'DOCKER_OPTS="-H 0.0.0.0:5432"' >> /etc/default/docker
service docker restart
sleep 10

docker -H ":5432" run -v /usr/local/bin:/target jpetazzo/nsenter
docker -H ":5432" pull ubuntu:14.04

# for td-agent
cat <<EOF > /etc/security/limits.d/fd.conf
root soft nofile 65536
root hard nofile 65536
* soft nofile 65536
* hard nofile 65536
EOF

cat <<EOF > /etc/sysctl.d/add_params.conf
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 10240    65535
EOF

cat <<EOF > /etc/initscript
ulimit -n 65536
eval exec "\$4"
EOF

apt-get autoremove && apt-get autoclean \
    && apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*
