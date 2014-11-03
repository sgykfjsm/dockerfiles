FROM ubuntu:14.04
MAINTAINER shigeyuki.fujishima_at_gmail.com

# initial setup
ENV DEBIAN_FRONTEND noninteractive
ENV APP_CONTAINER_NAME nginx
ENV DATA_CONTAINER_NAME data
ENV LOG_CONTAINER_NAME td

# environment
RUN locale-gen en_US.UTF-8 \
      && update-locale LANG=en_US.UTF-8 \
      && dpkg-reconfigure locales
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# networking
RUN echo "nameserver 8.8.8.8" >> /etc/resolvconf/resolv.conf.d/base

# repository
# if your region is not Tokyo, remove ADD line.
ADD jp.sources.list /etc/apt/sources.list
RUN apt-get -qq update && apt-get -qq -y upgrade

# install
RUN apt-get -y install git gcc g++ make curl monit ruby ruby-dev openssl libssl-dev openjdk-7-jdk

# monit
ADD etc_monit_conf.d_monit.conf /etc/monit/conf.d/monit.conf
ADD etc_monit_conf.d_td-agent.conf /etc/monit/conf.d/td-agent.conf
RUN mkdir -m 755 -p /var/log/monit \
      && sed -i -e "s/%CONTAINER_NAME%/${LOG_CONTAINER_NAME}/g" /etc/monit/conf.d/monit.conf

# ruby
RUN git clone https://github.com/sstephenson/rbenv.git /usr/local/share/.rbenv \
      && echo 'export PATH="/usr/local/share/.rbenv/bin:$PATH"' >> /root/.profile \
      && echo 'eval "$(rbenv init -)"' >> /root/.profile \
      && . /root/.profile \
      && git clone https://github.com/sstephenson/ruby-build.git /usr/local/share/.rbenv/plugins/ruby-build \
      && PREFIX=/usr/local /usr/local/share/.rbenv/plugins/ruby-build/install.sh \
      && rbenv install 2.1.4 \
      && rbenv rehash \
      && rbenv global 2.1.4 \
      && rbenv install jruby-1.7.16

# td-agent
ADD etc_security_limits.d_fd.conf /etc/security/limits.d/fd.conf
ADD etc_sysctl.d_params.conf /etc/sysctl.d/params.conf
ADD etc_initscript /etc/initscript
RUN curl --silent -L http://toolbelt.treasuredata.com/sh/install-ubuntu-trusty-td-agent2.sh | sh
RUN [ -d "/var/log/td-agent" ] && chown -R td-agent:td-agent "/var/log/td-agent" || :

# finish
RUN apt-get autoremove \
      && apt-get autoclean \
      && apt-get clean \
      && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*
RUN /etc/init.d/td-agent start
CMD ["/usr/bin/monit", "-I", "-c", "/etc/monit/monitrc"]
