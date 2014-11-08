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

COPY etc/security/limits.d/fd.conf /etc/security/limits.d/fd.conf
COPY etc/sysctl.d/params.conf /etc/sysctl.d/params.conf
COPY etc/initscript /etc/initscript

#
RUN echo "nameserver 8.8.8.8" >> /etc/resolvconf/resolv.conf.d/base \
    && apt-get -qq update && apt-get -qq -y upgrade \
    && apt-get autoremove \
    && apt-get autoclean \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*
