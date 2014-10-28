#!/bin/bash

apt-get -y update
apt-get -y upgrade
apt-get -y install git gcc mercurial liblua5.2-dev liblua5.2-0 libncurses5-dev luajit libluajit-5.1-dev
apt-get clean && apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

# gist setting

## https://gist.github.com/sgykfjsm/8426961
curl --silent https://gist.githubusercontent.com/sgykfjsm/8426961/raw/f5d155e14d295c1fa0803957e5041c83f6fb4f7f/.vimrc > /home/vagrant/.vimrc

## https://gist.github.com/sgykfjsm/9845504
curl --silent https://gist.githubusercontent.com/sgykfjsm/9845504/raw/4d403494a87d227094da4a2f8215f6c2ff1d5438/bash_profile > /home/vagrant/.bash_profile
echo 'export PATH=${PATH}:/usr/local/bin:${HOME}/local/bin' >> /home/vagrant/.bash_profile

hg clone -r 0446fa17bd95cdb37cd0c14ada32818b43577597 https://vim.googlecode.com/hg/ /usr/local/src/vim7.4.475
cd /usr/local/src/vim7.4.475
./configure --enable-multibyte --with-features=huge --disable-selinux --prefix=/usr/local --enable-luainterp=yes --with-lua-prefix=/usr --disable-darwin -with-luajit  --enable-fail-if-missing
make && sudo make install

git clone https://github.com/gmarik/Vundle.vim.git /home/vagrant/.vim/bundle/Vundle.vim

chown -R vagrant:vagrant /home/vagrant

apt-get -y update
apt-get -y install docker.io
ln -sf /usr/bin/docker.io /usr/local/bin/docker
sed -i '$acomplete -F _docker docker' /etc/bash_completion.d/docker.io
source /etc/bash_completion.d/docker.io

echo source /etc/bash_completion.d/docker.io >> /home/vagrant/.bash_profile
