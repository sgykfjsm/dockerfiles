FROM sgykfjsm/base_ubuntu:latest
MAINTAINER shigeyuki.fujishima_at_gmail.com

# initial setup
ENV CONTAINER_NAME php5fpm

# networking
EXPOSE 80 2812

# install
RUN apt-get -qq update && apt-get -y install \
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
COPY etc/monit/conf.d/monit.conf etc/monit/conf.d/php5fpm.conf /etc/monit/conf.d/
RUN mkdir -m 755 -p /var/log/monit \
      && sed -i -e "s/%CONTAINER_NAME%/${CONTAINER_NAME}/g" /etc/monit/conf.d/monit.conf

# php
COPY etc/php5/fpm/php.ini /tmp/php.ini
COPY etc/php5/fpm/pool.d/www.conf /etc/php5/fpm/pool.d/www.conf
RUN cat /tmp/php.ini >> /etc/php5/fpm/php.ini && rm -f /tmp/php.ini

# finish
RUN apt-get autoremove \
      && apt-get autoclean \
      && apt-get clean \
      && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*
CMD ["/usr/bin/monit", "-I", "-c", "/etc/monit/monitrc"]
