FROM ubuntu:14.04
MAINTAINER Nathan Warner <nathan@frcv.net>

ENV SALT_VERSION 2015.8.1+ds-1
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C

ADD SALTSTACK-GPG-KEY.pub /tmp/SALTSTACK-GPG-KEY.pub
RUN echo "deb http://repo.saltstack.com/apt/ubuntu/ubuntu14/latest trusty main" > /etc/apt/sources.list.d/salt.list && \
    apt-key add /tmp/SALTSTACK-GPG-KEY.pub && \
    rm /tmp/SALTSTACK-GPG-KEY.pub

RUN apt-get --quiet --yes update && \
    apt-get --quiet --yes install \
      salt-master=${SALT_VERSION} \
      salt-api=${SALT_VERSION} \
      python-git \
      python-openssl \
      python-pip \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists

RUN pip install --upgrade cherrypy

ADD run.sh /run.sh
RUN chmod a+x /run.sh

VOLUME ["/config"]

# salt-master, salt-api, halite
EXPOSE 4505 4506 443 4430

ENV BEFORE_EXEC_SCRIPT /config/before-exec.sh
ENV SALT_API_CMD /usr/bin/salt-api -c /config -d
ENV EXEC_CMD /usr/bin/salt-master -c /config -l debug

CMD ["/run.sh"]
