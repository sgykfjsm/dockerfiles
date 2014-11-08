FROM sgykfjsm/base_ubuntu:latest
MAINTAINER shigeyuki.fujishima_at_gmail.com

ENV CONTAINER_NAME ruby
ENV SHELL /bin/bash
ENV RUBY_VERSION 2.1.4
ENV RBENV_ROOT /usr/local/rbenv
ENV PATH ${RBENV_ROOT}/shims:${RBENV_ROOT}/bin:${PATH}

RUN apt-get -qq update && apt-get -qq -y install \
        autoconf \
        bison \
        build-essential \
        curl \
        git \
        libncurses5-dev \
        libreadline6-dev \
        libssl-dev \
        libyaml-dev \
        ruby-dev \
        zlib1g-dev \
      && git clone https://github.com/sstephenson/rbenv.git ${RBENV_ROOT} \
      && git clone https://github.com/sstephenson/ruby-build.git \
          ${RBENV_ROOT}/plugins/ruby-build \
      && PREFIX=/usr/local ${RBENV_ROOT}/plugins/ruby-build/install.sh \
      && echo 'eval "$(rbenv init -)"' | tee -a /etc/profile /root/.bashrc > /dev/null 2>&1 \
      && /bin/bash -l -c ". /etc/profile; . /root/.bashrc; rbenv install ${RUBY_VERSION}; rbenv local ${RUBY_VERSION}; rbenv rehash ;rbenv global ${RUBY_VERSION}; gem update --no-document;" \
      && gem install bundler --no-document \
      && apt-get autoremove \
      && apt-get autoclean \
      && apt-get clean \
      && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*
