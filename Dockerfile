FROM debian:jessie
MAINTAINER Nathan Warner <nathan@frcv.net>

ENV SALT_VERSION 2015.8.0+ds-2
ENV DEBIAN_FRONTEND noninteractive

RUN echo "deb http://repo.saltstack.com/apt/debian jessie contrib" > /etc/apt/sources.list.d/salt.list
ADD SALTSTACK-GPG-KEY.pub /tmp/SALTSTACK-GPG-KEY.pub
RUN apt-key add /tmp/SALTSTACK-GPG-KEY.pub && \
    rm /tmp/SALTSTACK-GPG-KEY.pub


RUN apt-get --quiet --yes update && \
    apt-get --quiet --yes install \
      salt-master=${SALT_VERSION} \
      salt-api=${SALT_VERSION} \
      python-git \
      python-openssl \
      python-cherrypy3 \
      python-pip \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists

RUN pip install Halite

ADD run.sh /run.sh
RUN chmod a+x /run.sh

VOLUME ["/config"]

# salt-master, salt-api, halite
EXPOSE 4505 4506 443 4430

ENV BEFORE_EXEC_SCRIPT /config/before-exec.sh
ENV SALT_API_CMD /usr/bin/salt-api -c /config -d
ENV EXEC_CMD /usr/bin/salt-master -c /config -l debug

CMD ["/run.sh"]
