#!/bin/bash

set -eu

export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
locale-gen en_US.UTF-8
dpkg-reconfigure locales

apt-get -qq -y update && apt-get -qq -y upgrade
apt-get -qq -y install git gcc ntp
apt-get autoremove && apt-get autoclean \
    && apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

chown -R vagrant:vagrant /home/vagrant/.

curl --silent -L http://toolbelt.treasuredata.com/sh/install-ubuntu-trusty-td-agent2.sh | sh
curl -sSL https://get.docker.com/ubuntu/ | sh
curl --silent https://raw.githubusercontent.com/docker/docker/master/contrib/completion/bash/docker > /etc/bash_completion.d/docker
source /etc/bash_completion.d/docker

echo source /etc/bash_completion.d/docker >> /home/vagrant/.bash_profile
echo 'DOCKER_OPTS="-H 0.0.0.0:5432"' >> /etc/default/docker
service docker restart

