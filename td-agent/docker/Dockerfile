FROM sgykfjsm/base_ubuntu:latest
MAINTAINER shigeyuki.fujishima_at_gmail.com

#
ENV CONTAINER_NAME td
ENV PATH ${PATH}:/opt/td-agent/embedded/bin:/opt/td-agent/bin

# networking
EXPOSE 2812 24220 8888 24224 24230

# monit
RUN apt-get -qq update && apt-get -qq -y install build-essential curl monit
COPY etc/monit/conf.d/monit.conf etc/monit/conf.d/td.conf \
       etc/monit/conf.d/norikra.conf /etc/monit/conf.d/
RUN mkdir -m 755 -p /var/log/monit \
      && sed -i -e "s/%CONTAINER_NAME%/${CONTAINER_NAME}/g" /etc/monit/conf.d/monit.conf

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
      && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*
CMD ["/usr/bin/monit", "-I", "-c", "/etc/monit/monitrc"]
