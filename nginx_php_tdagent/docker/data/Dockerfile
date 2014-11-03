FROM ubuntu:14.04
MAINTAINER shigeyuki.fujishima_at_gmail.com

# initial setup
ENV DEBIAN_FRONTEND noninteractive
ENV APP_CONTAINER_NAME nginx
ENV DATA_CONTAINER_NAME data
ENV LOG_CONTAINER_NAME td

# environment
RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8
RUN dpkg-reconfigure locales
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
