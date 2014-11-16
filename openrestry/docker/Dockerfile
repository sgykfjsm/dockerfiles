FROM sgykfjsm/base_ubuntu:latest
MAINTAINER shigeyuki.fujishima_at_gmail.com

# initial setup
ENV CONTAINER_NAME openresty
ENV OPENRESTY_VERSION 1.7.4.1
ENV OPENRESTY_DIR /opt/openresty

# networking
EXPOSE 80 2812 27989

# repository
# if your region is not Tokyo, remove ADD line.
# ADD jp.sources.list /etc/apt/sources.list
RUN apt-get -qq update \
      && apt-get -y build-dep nginx \
      && apt-get -y -qq install \
        libssl-dev \
        monit \
        openssl \
        redis-server \
        redis-tools \
        --no-install-recommends

# monit
RUN mkdir -m 755 -p /var/log/monit
COPY etc/monit/conf.d/monit.conf etc/monit/conf.d/nginx.conf etc/monit/conf.d/redis.conf \
       /etc/monit/conf.d/
RUN sed -i -e "s/%CONTAINER_NAME%/${CONTAINER_NAME}/g" /etc/monit/conf.d/monit.conf

# redis
RUN echo 'include /etc/redis/conf.d/default.conf' >> /etc/redis/redis.conf \
      && mkdir -m 755 -p /etc/redis/conf.d /var/run/redis /var/log/redis \
      && chown redis:redis /etc/redis/conf.d /var/run/redis /var/log/redis \
      && echo 'ULIMIT=65536' >> /etc/default/redis.conf
COPY etc/redis/conf.d/default.conf /etc/redis/conf.d/default.conf

# nginx
ADD openresty/ngx_openresty-${OPENRESTY_VERSION}.tar.gz /tmp/
RUN cd /tmp/ngx_openresty-${OPENRESTY_VERSION} \
      && mkdir -m 755 -p ${OPENRESTY_DIR} /var/run/nginx /var/log/nginx \
        /var/cache/nginx/clinet/body /var/cache/nginx/proxy \
        /etc/nginx/conf.d /var/cache/nginx/fastcgi \
        /usr/share/nginx/html \
      && ./configure \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --http-client-body-temp-path=/var/cache/nginx/client_body \
        --http-fastcgi-temp-path=/var/cache/nginx/fastcgi \
        --http-log-path=/var/log/nginx/access.log \
        --http-proxy-temp-path=/var/cache/nginx/proxy \
        --lock-path=/var/run/nginx/nginx.lock \
        --pid-path=/var/run/nginx/nginx.pid \
        --prefix=${OPENRESTY_DIR} \
        --sbin-path=/usr/local/sbin/nginx \
        --with-http_addition_module \
        --with-http_geoip_module \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_iconv_module \
        --with-http_image_filter_module \
        --with-http_realip_module \
        --with-http_ssl_module \
        --with-http_stub_status_module \
        --with-http_xslt_module \
        --with-ipv6 \
        --with-luajit \
        --with-luajit-xcflags=-DLUAJIT_ENABLE_CHECKHOOK \
        --with-pcre-jit \
        --without-http_scgi_module \
        --without-http_uwsgi_module \
      && make \
      && make install
COPY etc/nginx/nginx.conf /etc/nginx/nginx.conf
COPY etc/nginx/conf.d/redirect.conf etc/nginx/conf.d/lua.conf /etc/nginx/conf.d/
COPY etc/init.d/nginx /etc/init.d/nginx
RUN sed -i -e "s/%CONTAINER_NAME%/${CONTAINER_NAME}/g" /etc/nginx/nginx.conf \
      && sed -i -e "s/%CONTAINER_NAME%/${CONTAINER_NAME}/g" /etc/nginx/conf.d/redirect.conf \
      && sed -i -e "s/%CONTAINER_NAME%/${CONTAINER_NAME}/g" /etc/nginx/conf.d/lua.conf \
      && chmod 755 /etc/init.d/nginx

# finish
RUN apt-get autoremove \
      && apt-get autoclean \
      && apt-get clean \
      && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* /tmp/ngx-openresty*
CMD ["/usr/bin/monit", "-I", "-c", "/etc/monit/monitrc"]
