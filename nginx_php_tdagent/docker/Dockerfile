FROM sgykfjsm/base_ubuntu:latest

MAINTAINER shigeyuki.fujishima_at_gmail.com

ENV CONTAINER_NAME nginx_php_tdagent
ENV PATH ${PATH}:/opt/td-agent/embedded/bin:/opt/td-agent/bin

# networking
EXPOSE 80 2812 24220 8888 24224 24230

# repository
# if your region is not Tokyo, remove ADD line.
# ADD jp.sources.list /etc/apt/sources.list
RUN apt-get -qq update && apt-get -y install \
      build-essential curl monit \
      python-software-properties \
      software-properties-common \
      && add-apt-repository ppa:nginx/stable \
      && apt-get -qq update \
      && apt-get -y install nginx --no-install-recommends \
      && apt-get -qq update && apt-get -y install \
      liboauth-php \
      libssh2-php \
      mcrypt \
      monit \
      php-aws-sdk \
      php5 \
      php5-apcu \
      php5-cli \
      php5-dev \
      php5-fpm \
      php5-gd \
      php5-imagick \
      php5-intl \
      php5-mcrypt \
      php5-mcrypt \
      php5-memcache \
      php5-memcached \
      php5-mysqlnd \
      php5-oauth \
      php5-odbc \
      php5-pgsql \
      php5-sqlite \
      php5-xmlrpc \
      php5-xsl \
      re2c \
      uuid-dev \
      && pecl -q install uuid igbinary \
      && mkdir -p /tmp/apt-get-source/ \
      && cd $_ \
      && apt-get -qq source php5 \
      && cd $(find $(pwd) -type d -name "*php5*")/ext/pcntl \
      && phpize \
      && ./configure -q \
      && make \
      && make install

# monit
COPY etc/monit/conf.d/php5fpm.conf etc/monit/conf.d/monit.conf etc/monit/conf.d/td.conf etc/monit/conf.d/nginx.conf /etc/monit/conf.d/
# COPY etc/monit/conf.d/php5fpm.conf etc/monit/conf.d/monit.conf etc/monit/conf.d/nginx.conf /etc/monit/conf.d/
RUN mkdir -m 755 -p /var/log/monit

# nginx
RUN rm -rf /etc/nginx/sites-available /usr/share/nginx/html \
      && mkdir -m 755 -p /etc/nginx/sites-available /usr/share/nginx/html
COPY etc/nginx/nginx.conf /etc/nginx/nginx.conf
COPY etc/nginx/sites-available/default /etc/nginx/sites-available/default
COPY usr/share/nginx/html/index.html usr/share/nginx/html/index.php /usr/share/nginx/html/

# php
COPY etc/php5/fpm/php.ini /tmp/php.ini
COPY etc/php5/fpm/pool.d/www.conf /etc/php5/fpm/pool.d/www.conf
RUN cat /tmp/php.ini >> /etc/php5/fpm/php.ini && rm -f /tmp/php.ini

# td-agent and more
RUN curl --silent -L http://toolbelt.treasuredata.com/sh/install-ubuntu-trusty-td-agent2.sh | sh \
      && echo 'include conf.d/*.conf' >> /etc/td-agent/td-agent.conf \
      && mkdir -m 755 -p /etc/td-agent/td-agent/conf.d \
      && chown -R td-agent:td-agent /etc/td-agent/. \
      && fluent-gem install fluent-plugin-norikra --no-rdoc --no-ri --quiet

# finish
RUN apt-get autoremove \
      && apt-get autoclean \
      && apt-get clean \
      && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* /var/run/monit.pid

CMD ["/usr/bin/monit", "-I", "-c", "/etc/monit/monitrc"]
