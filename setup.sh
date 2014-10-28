#!/bin/bash

set -eu

export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
locale-gen en_US.UTF-8
dpkg-reconfigure locales

apt-get -qq -y update && apt-get -qq -y upgrade
apt-get -qq -y install git gcc mercurial liblua5.2-dev liblua5.2-0 libncurses5-dev luajit libluajit-5.1-dev
apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

# setting from gist

# ## https://gist.github.com/sgykfjsm/8426961
# curl --silent https://gist.githubusercontent.com/sgykfjsm/8426961/raw/f5d155e14d295c1fa0803957e5041c83f6fb4f7f/.vimrc > /home/vagrant/.vimrc
#
# ## https://gist.github.com/sgykfjsm/9845504
# curl --silent https://gist.githubusercontent.com/sgykfjsm/9845504/raw/4d403494a87d227094da4a2f8215f6c2ff1d5438/bash_profile > /home/vagrant/.bash_profile
# echo 'export PATH=/usr/local/bin:${HOME}/local/bin:${PATH}' >> /home/vagrant/.bash_profile
#
# vim_src=/usr/local/src/vim7.4.475
# rm -rf ${vim_src}
# hg clone -r 0446fa17bd95cdb37cd0c14ada32818b43577597 https://vim.googlecode.com/hg/ ${vim_src}
# cd ${vim_src}
# ./configure --enable-multibyte --with-features=huge --disable-selinux --prefix=/usr/local --enable-luainterp=yes --with-lua-prefix=/usr --disable-darwin -with-luajit  --enable-fail-if-missing
# make && sudo make install
#
# vundle_dir=/home/vagrant/.vim/bundle/Vundle.vim
# rm -rf ${vundle_dir}
# git clone https://github.com/gmarik/Vundle.vim.git ${vundle_dir}

chown -R vagrant:vagrant /home/vagrant/.

curl -sSL https://get.docker.com/ubuntu/ | sh
curl --silent https://raw.githubusercontent.com/docker/docker/master/contrib/completion/bash/docker > /etc/bash_completion.d/docker
source /etc/bash_completion.d/docker

echo source /etc/bash_completion.d/docker >> /home/vagrant/.bash_profile
echo 'DOCKER_OPTS="-H 0.0.0.0:5432"' >> /etc/default/docker
service docker restart
sleep 10

docker -H ":5432" run -v /usr/local/bin:/target jpetazzo/nsenter
