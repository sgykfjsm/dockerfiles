FROM sgykfjsm/base_ubuntu:latest
MAINTAINER shigeyuki.fujishima_at_gmail.com

ENV CONTAINER_NAME jruby
ENV SHELL /bin/bash
ENV JRUBY_VERSION jruby-1.7.16
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
        openjdk-7-jdk \
        ruby-dev \
        zlib1g-dev \
      && git clone https://github.com/sstephenson/rbenv.git ${RBENV_ROOT} \
      && git clone https://github.com/sstephenson/ruby-build.git \
          ${RBENV_ROOT}/plugins/ruby-build \
      && PREFIX=/usr/local ${RBENV_ROOT}/plugins/ruby-build/install.sh \
      && echo 'eval "$(rbenv init -)"' | tee -a /etc/profile /root/.bashrc > /dev/null 2>&1 \
      && /bin/bash -l -c ". /etc/profile; . /root/.bashrc; rbenv install ${JRUBY_VERSION}; rbenv local ${JRUBY_VERSION}; rbenv rehash ;rbenv global ${JRUBY_VERSION}; gem update --no-document;" \
      && gem install bundler --no-document \
      && apt-get autoremove \
      && apt-get autoclean \
      && apt-get clean \
      && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*
