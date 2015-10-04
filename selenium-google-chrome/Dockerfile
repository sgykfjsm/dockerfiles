FROM ubuntu:15.04

MAINTAINER Shigeyuki Fujishima <shigeyuki.fujishima_at_gmail.com>

ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

ENV SCREEN_WIDTH 1360
ENV SCREEN_HEIGHT 1020
ENV SCREEN_DEPTH 24
ENV DISPLAY :99.0

# --- based on https://github.com/SeleniumHQ/docker-selenium/blob/master/Base/Dockerfile
#================================================
# Customize sources for apt-get
#================================================
RUN echo "deb http://archive.ubuntu.com/ubuntu vivid main universe\n" > /etc/apt/sources.list \
    && echo "deb http://archive.ubuntu.com/ubuntu vivid-updates main universe\n" >> /etc/apt/sources.list

#========================
# Miscellaneous packages
# Includes sevelral package for maven testing
#========================
RUN apt-get update -y \
    && apt-get -y --no-install-recommends install \
    ca-certificates \
    curl \
    git \
    maven \
    openjdk-8-jdk \
    sudo \
    unzip \
    wget \
    xvfb \
    && rm -rf /var/lib/apt/lists/* \
    && sed -i 's/\/dev\/urandom/\/dev\/.\/urandom/' ./usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/java.security \
    && update-ca-certificates -f

#==========
# Selenium
#==========
RUN mkdir -p /opt/selenium \
    && wget --no-verbose http://selenium-release.storage.googleapis.com/2.47/selenium-server-standalone-2.47.1.jar -O /opt/selenium/selenium-server-standalone.jar

#========================================
# Add normal user with passwordless sudo
#========================================
RUN sudo useradd seluser --shell /bin/bash --create-home \
    && sudo usermod -a -G sudo seluser \
    && echo 'ALL ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers \
    && echo 'seluser:secret' | chpasswd

# --- based on https://github.com/SeleniumHQ/docker-selenium/blob/master/NodeBase/Dockerfile
#===================
# Timezone settings
# Possible alternative: https://github.com/docker/docker/issues/3359#issuecomment-32150214
#===================
ENV TZ "UTC"
RUN echo "UTC" | sudo tee /etc/timezone \
    && dpkg-reconfigure --frontend noninteractive tzdata

# --- https://github.com/SeleniumHQ/docker-selenium/blob/master/NodeChrome/Dockerfile
#===============
# Google Chrome
#===============
RUN wget -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update -y \
    && apt-get -y install google-chrome-stable \
    && rm -f /etc/apt/sources.list.d/google-chrome.list \
    && rm -rf /var/lib/apt/lists/*

#==================
# Chrome webdriver
#==================
ENV CHROME_DRIVER_VERSION 2.18
RUN wget -O /tmp/chromedriver_linux64.zip http://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip \
    && rm -rf /opt/selenium/chromedriver \
    && unzip /tmp/chromedriver_linux64.zip -d /opt/selenium \
    && rm -f /tmp/chromedriver_linux64.zip \
    && mv /opt/selenium/chromedriver /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION \
    && chmod 755 /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION \
    && ln -fs /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION /usr/bin/chromedriver

#========================
# Selenium Configuration
#========================
COPY config.json /opt/selenium/config.json

#=================================
# Chrome Launch Script Modication
#=================================
COPY chrome_launcher.sh /opt/google/chrome/google-chrome
RUN chmod +x /opt/google/chrome/google-chrome

# ---- https://github.com/SeleniumHQ/docker-selenium/blob/master/StandaloneChrome/Dockerfile
#====================================
# Scripts to run Selenium Standalone
#====================================
COPY entry_point.sh /opt/bin/entry_point.sh
RUN chmod +x /opt/bin/entry_point.sh

# cleanup
RUN apt-get autoremove \
    && apt-get autoclean \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

USER seluser

EXPOSE 4444
ENTRYPOINT ["/opt/bin/entry_point.sh"]
# EOF
