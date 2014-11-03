FROM sgykfjsm/php5fpm:latest
MAINTAINER shigeyuki.fujishima_at_gmail.com

ENV CONTAINER_NAME nginx_php5fpm

# networking
EXPOSE 80

# repository
# if your region is not Tokyo, remove ADD line.
# ADD jp.sources.list /etc/apt/sources.list
RUN apt-get -qq update && apt-get -qq -y upgrade \
      && apt-get -y install \
      python-software-properties \
      software-properties-common \
      --no-install-recommends \
      && add-apt-repository ppa:nginx/stable \
      && apt-get -qq update && apt-get -qq -y upgrade \
      && apt-get -y install nginx --no-install-recommends

# monit
ADD etc_monit_conf.d_nginx.conf /etc/monit/conf.d/nginx.conf

# nginx
RUN rm -rf /etc/nginx/sites-available /usr/share/nginx/html \
      && mkdir -m 755 -p /etc/nginx/sites-available /usr/share/nginx/html
ADD etc_nginx_nginx.conf /etc/nginx/nginx.conf
ADD etc_nginx_sites-available_default /etc/nginx/sites-available/default
ADD usr_share_nginx_html_index.html /usr/share/nginx/html/index.html
ADD usr_share_nginx_html_index.php  /usr/share/nginx/html/index.php
RUN sed -i -e "s/%CONTAINER_NAME%/${CONTAINER_NAME}/g" /etc/nginx/sites-available/default

# finish
RUN apt-get autoremove \
      && apt-get autoclean \
      && apt-get clean \
      && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* \
      && rm -f /var/run/nginx.pid && rm -f /var/run/php5-fpm.pid && rm -f /var/run/monit.pid \
      && /bin/bash /etc/init.d/nginx start \
      && /bin/bash /etc/init.d/php5-fpm start
CMD ["/usr/bin/monit", "-I", "-c", "/etc/monit/monitrc"]
