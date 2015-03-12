FROM sgykfjsm/base_ubuntu:latest
MAINTAINER shigeyuki.fujishima_at_gmail.com

# initial setup
ENV CONTAINER_NAME play-scala-intro

# networking
EXPOSE 9000 2812

RUN rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* \
        && apt-get -qq update -y \
        && apt-get -qq install -y \
            unzip \
            monit \
            openjdk-7-jre-headless \
            --no-install-recommends \
        && apt-get autoremove \
        && apt-get autoclean \
        && apt-get clean \
        && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

# setup
RUN mkdir -m 755 -p /var/log/monit /opt

# monit
COPY etc/monit/conf.d/monit.conf etc/monit/conf.d/application.conf /etc/monit/conf.d/

# application
COPY app/play-scala-intro-1.0-SNAPSHOT.zip /opt/

#
RUN sed -i -e "s/%CONTAINER_NAME%/${CONTAINER_NAME}/g" /etc/monit/conf.d/monit.conf \
    && unzip /opt/play-scala-intro-1.0-SNAPSHOT.zip -d /opt/

# start
CMD ["/usr/bin/monit", "-I", "-c", "/etc/monit/monitrc"]
