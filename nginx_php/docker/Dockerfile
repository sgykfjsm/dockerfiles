FROM sgykfjsm/php5fpm:latest
MAINTAINER shigeyuki.fujishima_at_gmail.com

ENV CONTAINER_NAME nginx_php5fpm

# networking
EXPOSE 80

# repository
# if your region is not Tokyo, remove ADD line.
# ADD jp.sources.list /etc/apt/sources.list
RUN apt-get -qq update && apt-get -y install \
      python-software-properties \
      software-properties-common \
      && add-apt-repository ppa:nginx/stable \
      && apt-get -qq update \
      && apt-get -y install nginx --no-install-recommends

# monit
COPY etc/monit/conf.d/nginx.conf /etc/monit/conf.d/nginx.conf

# nginx
RUN rm -rf /etc/nginx/sites-available /usr/share/nginx/html \
      && mkdir -m 755 -p /etc/nginx/sites-available /usr/share/nginx/html
COPY etc/nginx/nginx.conf /etc/nginx/nginx.conf
COPY etc/nginx/sites-available/default /etc/nginx/sites-available/default
COPY usr/share/nginx/html/index.html usr/share/nginx/html/index.php /usr/share/nginx/html/

# finish
RUN apt-get autoremove \
      && apt-get autoclean \
      && apt-get clean \
      && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* /var/run/monit.pid
CMD ["/usr/bin/monit", "-I", "-c", "/etc/monit/monitrc"]
