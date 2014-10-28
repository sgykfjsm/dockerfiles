FROM ubuntu:14.04
MAINTAINER shigeyuki.fujishima_at_gmail.com

#
ENV DEBIAN_FRONTEND noninteractive
ENV CONTAINER_NAME app1

#
RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8
RUN dpkg-reconfigure locales
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

#
ADD jp.sources.list /etc/apt/sources.list
RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install python-software-properties software-properties-common
RUN add-apt-repository ppa:nginx/stable

#
RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install nginx monit --no-install-recommends
RUN apt-get clean && rm -rf /var/cache/apt/archives/* && rm -rf /var/lib/apt/lists/*

#
EXPOSE 80
EXPOSE 2812

#
RUN mkdir -m 755 -p /var/log/monit
RUN mkdir -p /etc/nginx/sites-available
ADD etc_nginx_nginx.conf /etc/nginx/nginx.conf
ADD etc_nginx_sites-available_app1 /etc/nginx/sites-available/app1
ADD etc_monit_conf.d_monit.conf /etc/monit/conf.d/monit.conf
ADD etc_monit_conf.d_nginx.conf /etc/monit/conf.d/nginx.conf

#
RUN sed -i -e "s/%CONTAINER_NAME%/${CONTAINER_NAME}/g" -e "s/#.*//g" /etc/monit/conf.d/nginx.conf
RUN sed -i -e "s/%CONTAINER_NAME%/${CONTAINER_NAME}/g" -e "s/#.*//g" /etc/monit/conf.d/monit.conf
RUN sed -i -e "s/%CONTAINER_NAME%/${CONTAINER_NAME}/g" -e "s/#.*//g" /etc/nginx/sites-available/app1


# finish
RUN /etc/init.d/nginx start
CMD ["/usr/bin/monit", "-I", "-c", "/etc/monit/monitrc"]
