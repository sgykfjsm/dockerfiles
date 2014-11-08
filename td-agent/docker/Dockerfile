FROM sgykfjsm/ruby:latest
MAINTAINER shigeyuki.fujishima_at_gmail.com

#
ENV CONTAINER_NAME td
ENV PATH ${PATH}:/opt/td-agent/embedded/bin:/opt/td-agent/bin
ENV NORIKRA_DIR /opt/norikra

# networking
EXPOSE 2812 26578

# monit
RUN apt-get -qq update && apt-get -qq -y install monit --no-install-recommends
COPY etc/monit/conf.d/monit.conf etc/monit/conf.d/td.conf \
       etc/monit/conf.d/norikra.conf /etc/monit/conf.d/
RUN mkdir -m 755 -p /var/log/monit \
      && sed -i -e "s/%CONTAINER_NAME%/${CONTAINER_NAME}/g" /etc/monit/conf.d/monit.conf

# td-agent and more
## To install norikra, I need 'rbenv shell'.
## so, I have to read bash-profile by `/bin/bash -l -c`.
## JRUBY_VERSION is environment variable from sgykfjsm/ruby.
# COPY opt/norikra/norikra.sh /etc/init.d/norikra
RUN curl --silent -L http://toolbelt.treasuredata.com/sh/install-ubuntu-trusty-td-agent2.sh | sh \
      && echo 'include conf.d/*.conf' >> /etc/td-agent/td-agent.conf \
      && mkdir -m 755 -p /etc/td-agent/td-agent/conf.d \
      && chown -R td-agent:td-agent /etc/td-agent/. \
      && fluent-gem install fluent-plugin-norikra --no-rdoc --no-ri --quiet \
      && /bin/bash -l -c "rbenv shell ${JRUBY_VERSION} && gem install norikra --platform jruby --no-document --quiet" \
      && useradd norikra --shell /bin/false -M \
      && mkdir -m 755 -p "${NORIKRA_DIR}/log" "${NORIKRA_DIR}/out" "${NORIKRA_DIR}/stats"
COPY etc/init.d/norikra /etc/init.d/norikra
COPY opt/norikra/norikra.sh /opt/norikra/norikra

# finish
RUN apt-get autoremove \
      && apt-get autoclean \
      && apt-get clean \
      && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* \
      && chmod +x /etc/init.d/norikra \
      && chmod +x /opt/norikra/norikra \
      && ln -sf /usr/local/rbenv/bin/rbenv /usr/bin/rbenv \
      && ln -sf $(which norikra) /usr/bin/norikra
#       && /etc/init.d/td-agent start \
#       && /etc/init.d/norikra start
#       && update-rc.d norikra default
CMD ["/usr/bin/monit", "-vv",  "-I", "-c", "/etc/monit/monitrc"]
