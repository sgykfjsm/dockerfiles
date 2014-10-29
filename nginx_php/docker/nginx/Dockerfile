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
      && apt-get -qq -y install python-software-properties software-properties-common \
      && add-apt-repository ppa:nginx/stable

# install
RUN apt-get -qq update && apt-get -qq -y upgrade \
      && apt-get -qq -y install \
      nginx \
      monit \
      re2c \
      php5 \
      php5-cli \
      php5-fpm \
      php5-mysql \
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
      && apt-get -qq -y install php5-mysqlnd \
      && pecl -q install uuid igbinary \
      && mkdir -p /tmp/apt-get-source/ \
      && cd $_ \
      && apt-get -qq source php5 \
      && cd $(find $(pwd) -type d -name "*php5*")/ext/pcntl \
      && phpize \
      && ./configure -q \
      && make \
      && make install
RUN echo '# from Dockerfile\nexpose_php = Off\nhtml_errors = Off\nvariables_order = "EGPCS"\nsession.save_path = "/tmp"\ndefault_socket_timeout = 90\npost_max_size = 32M\nshort_open_tag = 1\ndate.timezone = UTC\n' >> /etc/php5/fpm/php.ini \
      && echo '<?php\nphpinfo();\n' > /usr/share/nginx/html/index.php
ADD etc_php5_fpm_pool.d_www.conf /etc/php5/fpm/pool.d/www.conf
# ADD amzn_t1_micro_php55d.tar.gz /var/tmp/

# monit
ADD etc_monit_conf.d_monit.conf /etc/monit/conf.d/monit.conf
ADD etc_monit_conf.d_nginx.conf /etc/monit/conf.d/nginx.conf
RUN mkdir -m 755 -p /var/log/monit \
      && sed -i -e "s/%CONTAINER_NAME%/${APP_CONTAINER_NAME}/g" /etc/monit/conf.d/monit.conf \
      && sed -i -e "s/%CONTAINER_NAME%/${APP_CONTAINER_NAME}/g" /etc/monit/conf.d/nginx.conf

# nginx
RUN mkdir -p /etc/nginx/sites-available
ADD etc_nginx_nginx.conf /etc/nginx/nginx.conf
ADD etc_nginx_sites-available_app1 /etc/nginx/sites-available/app1
RUN sed -i -e "s/%CONTAINER_NAME%/${APP_CONTAINER_NAME}/g" /etc/nginx/sites-available/app1

# finish
RUN apt-get autoclean && apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*
RUN /etc/init.d/php5-fpm start \
    && /etc/init.d/nginx start
CMD ["/usr/bin/monit", "-I", "-c", "/etc/monit/monitrc"]
