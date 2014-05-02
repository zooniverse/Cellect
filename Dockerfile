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
RUN echo "deb http://us.archive.ubuntu.com/ubuntu trusty main universe" > /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y python-software-properties build-essential bison autoconf gcc-4.8 wget libxml2-dev libxslt1-dev zlib1g-dev openssl libssl-dev curl libcurl4-openssl-dev libffi-dev libreadline6 libreadline6-dev libboost1.55-dev supervisor

# Install libYAML
ADD http://pyyaml.org/download/libyaml/yaml-0.1.6.tar.gz /tmp/
RUN cd /tmp && tar -xzvf yaml-0.1.6.tar.gz && cd yaml-0.1.6 && \
./configure --prefix=/usr/local && make && make install && \
rm -rf /tmp/yaml*

# Install Ruby
ADD http://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.1.tar.gz /tmp/
RUN cd /tmp && tar -xvzf ruby-2.1.1.tar.gz && cd ruby-2.1.1 && \
curl -fsSL https://gist.github.com/mislav/a18b9d7f0dc5b9efc162.txt > fix-readlines && \
patch -p0 < fix-readlines && \
./configure --prefix=/usr/local --disable-install-doc --enable-shared --with-opt-dir=/usr/local/lib && \
make && make install && rm -rf /tmp/ruby*

# Install Cellect
WORKDIR /cellect
ADD Gemfile /cellect/Gemfile
ADD Gemfile.lock /cellect/Gemfile.lock
RUN gem install bundler && bundle install

ADD ./ /cellect
WORKDIR ext
RUN rm -f Makefile && ruby extconf.rb && make clean && make

EXPOSE 3000
WORKDIR /cellect

ADD script/start_puma /opt/start_puma
ADD config/supervisor.conf /etc/supervisor/conf.d/cellect.conf
CMD ["/usr/bin/supervisord"]

# docker run -i --publish 3000:3000 --link pg:pg --link mongo:mongo --link zk:zk -t parrish/cellect /bin/bash
