FROM ubuntu:14.04
MAINTAINER shigeyuki.fujishima_at_gmail.com

# initial setup
ENV DEBIAN_FRONTEND noninteractive
ENV CONTAINER_NAME base

# environment
RUN locale-gen en_US.UTF-8 \
      && update-locale LANG=en_US.UTF-8 \
      && dpkg-reconfigure locales
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

ADD etc_security_limits.d_fd.conf /etc/security/limits.d/fd.conf
ADD etc_sysctl.d_params.conf /etc/sysctl.d/params.conf
ADD etc_initscript /etc/initscript

#
RUN echo "nameserver 8.8.8.8" >> /etc/resolvconf/resolv.conf.d/base
RUN apt-get -qq update && apt-get -qq -y upgrade

#
RUN apt-get autoremove \
      && apt-get autoclean \
      && apt-get clean \
      && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*
