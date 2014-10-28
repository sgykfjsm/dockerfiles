FROM ubuntu:14.04
MAINTAINER shigeyuki.fujishima_at_gmail.com

# initial setup
ENV DEBIAN_FRONTEND noninteractive
ENV APP_CONTAINER_NAME app1
ENV DATA_CONTAINER_NAME data1

# environment
RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8
RUN dpkg-reconfigure locales
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# networking
EXPOSE 80
EXPOSE 2812
RUN echo "nameserver 8.8.8.8" >> /etc/resolvconf/resolv.conf.d/base

# repository
# if your region is not Tokyo, remove ADD line.
ADD jp.sources.list /etc/apt/sources.list
RUN apt-get -qq update && apt-get -qq -y upgrade
RUN apt-get -qq -y install python-software-properties software-properties-common
RUN add-apt-repository ppa:nginx/stable

# install
RUN apt-get -qq update && apt-get -qq -y upgrade
RUN apt-get -qq -y install nginx monit --no-install-recommends

# monit
RUN mkdir -m 755 -p /var/log/monit
ADD etc_monit_conf.d_monit.conf /etc/monit/conf.d/monit.conf
ADD etc_monit_conf.d_nginx.conf /etc/monit/conf.d/nginx.conf
RUN sed -i -e "s/%CONTAINER_NAME%/${APP_CONTAINER_NAME}/g" /etc/monit/conf.d/monit.conf
RUN sed -i -e "s/%CONTAINER_NAME%/${APP_CONTAINER_NAME}/g" /etc/monit/conf.d/nginx.conf

# nginx
RUN mkdir -p /etc/nginx/sites-available
ADD etc_nginx_nginx.conf /etc/nginx/nginx.conf
ADD etc_nginx_sites-available_app1 /etc/nginx/sites-available/app1
RUN sed -i -e "s/%CONTAINER_NAME%/${APP_CONTAINER_NAME}/g" /etc/nginx/sites-available/app1

# finish
RUN apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*
RUN /etc/init.d/nginx start
CMD ["/usr/bin/monit", "-I", "-c", "/etc/monit/monitrc"]
