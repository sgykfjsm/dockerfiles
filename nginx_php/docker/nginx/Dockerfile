FROM ubuntu:14.04
MAINTAINER shigeyuki.fujishima_at_gmail.com

# initial setup
ENV DEBIAN_FRONTEND noninteractive
ENV APP_CONTAINER_NAME app1
ENV DATA_CONTAINER_NAME data1

# environment
RUN locale-gen en_US.UTF-8 \
      && update-locale LANG=en_US.UTF-8 \
      && dpkg-reconfigure locales
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# networking
EXPOSE 80 2812
RUN echo "nameserver 8.8.8.8" >> /etc/resolvconf/resolv.conf.d/base

# repository
# if your region is not Tokyo, remove ADD line.
ADD jp.sources.list /etc/apt/sources.list
RUN apt-get -qq update && apt-get -qq -y upgrade \
      && apt-get -y install \
      python-software-properties \
      software-properties-common \
      --no-install-recommends \
      && add-apt-repository ppa:nginx/stable

# install
RUN apt-get -qq update && apt-get -qq -y upgrade \
      && apt-get -y install \
      nginx \
      monit \
      --no-install-recommends

# monit
ADD etc_monit_conf.d_monit.conf /etc/monit/conf.d/monit.conf
ADD etc_monit_conf.d_nginx.conf /etc/monit/conf.d/nginx.conf
ADD etc_monit_conf.d_php5fpm.conf /etc/monit/conf.d/php5fpm.conf
RUN mkdir -m 755 -p /var/log/monit \
      && sed -i -e "s/%CONTAINER_NAME%/${APP_CONTAINER_NAME}/g" /etc/monit/conf.d/monit.conf

# nginx
RUN rm -rf /etc/nginx/sites-available \
      && mkdir -p /etc/nginx/sites-available \
      && rm -f /usr/share/nginx/html/index.html
ADD etc_nginx_nginx.conf /etc/nginx/nginx.conf
ADD etc_nginx_sites-available_app1 /etc/nginx/sites-available/app1
ADD usr_share_nginx_html_index.html /usr/share/nginx/html/index.html
RUN sed -i -e "s/%CONTAINER_NAME%/${APP_CONTAINER_NAME}/g" /etc/nginx/sites-available/app1

# install
RUN apt-get -qq update && apt-get -qq -y upgrade \
      && apt-get -y install \
      re2c \
      php5 \
      php5-cli \
      php5-fpm \
      php5-mysqlnd \
      php5-odbc \
      php5-pgsql \
      php5-sqlite \
      php-aws-sdk \
      php5-apcu \
      php5-imagick \
      php5-intl \
      php5-memcache \
      php5-memcached \
      php5-xsl \
      liboauth-php \
      libssh2-php \
      php5-oauth \
      php5-gd \
      php5-xmlrpc \
      php5-dev \
      php5-mcrypt \
      mcrypt \
      php5-mcrypt \
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

# php
ADD usr_share_nginx_html_index.php /usr/share/nginx/html/index.php
ADD etc_php5_fpm_php.ini /tmp/php.ini
ADD etc_php5_fpm_pool.d_www.conf /etc/php5/fpm/pool.d/www.conf
RUN cat /tmp/php.ini >> /etc/php5/fpm/php.ini && rm -f /tmp/php.ini
# ADD amzn_t1_micro_php55d.tar.gz /var/tmp/

# finish
RUN apt-get autoclean && apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*
RUN /etc/init.d/nginx start
RUN /etc/init.d/php5-fpm start
CMD ["/usr/bin/monit", "-I", "-c", "/etc/monit/monitrc"]
