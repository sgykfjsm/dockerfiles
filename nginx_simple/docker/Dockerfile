FROM sgykfjsm/base_ubuntu:latest
MAINTAINER shigeyuki.fujishima_at_gmail.com

# initial setup
ENV CONTAINER_NAME nginx

# networking
EXPOSE 80 2812

# repository
# if your region is not Tokyo, remove ADD line.
# ADD jp.sources.list /etc/apt/sources.list
RUN apt-get -qq update \
      && apt-get -qq -y install \
        python-software-properties \
        software-properties-common \
      && add-apt-repository ppa:nginx/stable \
      && apt-get -qq update \
      && apt-get -qq -y install \
        monit \
        nginx \
        --no-install-recommends

# monit
RUN mkdir -m 755 -p /var/log/monit
COPY etc/monit/conf.d/monit.conf etc/monit/conf.d/nginx.conf /etc/monit/conf.d/
RUN sed -i -e "s/%CONTAINER_NAME%/${CONTAINER_NAME}/g" /etc/monit/conf.d/monit.conf \
    && sed -i -e "s/%CONTAINER_NAME%/${CONTAINER_NAME}/g" /etc/monit/conf.d/nginx.conf

# nginx
RUN rm -rf /etc/nginx/sites-available /usr/share/nginx/html \
    && mkdir -m 755 -p /etc/nginx/sites-available /usr/share/nginx/html
COPY etc/nginx/nginx.conf /etc/nginx/nginx.conf
COPY etc/nginx/sites-available/default /etc/nginx/sites-available/default
COPY usr/share/nginx/html/index.html /usr/share/nginx/html/index.html
RUN sed -i -e "s/%CONTAINER_NAME%/${CONTAINER_NAME}/g" /etc/nginx/sites-available/default

# finish
RUN apt-get autoremove \
      && apt-get autoclean \
      && apt-get clean \
      && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*
CMD ["/usr/bin/monit", "-I", "-c", "/etc/monit/monitrc"]
