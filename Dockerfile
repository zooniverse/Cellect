# Cellect
# 
# VERSION 1.0

FROM ubuntu:14.04
MAINTAINER Michael Parrish <michael@zooniverse.org>

ENV DEBIAN_FRONTEND noninteractive
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Apt-get install dependencies
RUN apt-get update
RUN apt-get install -y build-essential libssl-dev libreadline-dev wget libc6-dev libssl-dev libreadline6-dev zlib1g-dev libyaml-dev libpq-dev autoconf libboost-all-dev libffi-dev supervisor

# Install ruby-build
RUN apt-get install -y git-core && apt-get clean
RUN git clone https://github.com/sstephenson/ruby-build.git && cd ruby-build && ./install.sh

# Install ruby 2.1.2
ENV CONFIGURE_OPTS --disable-install-rdoc --enable-shared
RUN ruby-build 2.1.2 /usr/local
RUN gem install bundler

# Install Cellect
WORKDIR /cellect
ADD . /cellect
RUN bundle install

EXPOSE 80

ADD script/start_puma /opt/start_puma
ADD config/supervisor.conf /etc/supervisor/conf.d/cellect.conf
RUN apt-get clean
CMD ["/usr/bin/supervisord"]

# docker run -i --link pg:pg --link zk:zk -v /vagrant:/cellect -t parrish/cellect /bin/bash
