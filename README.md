# Cellect

A scalable subject selector for [Panoptes](https://github.com/zooniverse/panoptes)

[![Build Status](https://travis-ci.org/zooniverse/Cellect.svg?branch=master)](https://travis-ci.org/zooniverse/Cellect)

Available as
  - [cellect-server](https://rubygems.org/gems/cellect-server)
  - [cellect-client](https://rubygems.org/gems/cellect-client)
  - [cellect](https://rubygems.org/gems/cellect)(combined)

## Cellect::Server

An actor based system that provides an API around subject selection actions.  Server nodes are discovered via [ZooKeeper](http://zookeeper.apache.org/).

### Cellect::Server::Adapters

[An adapter](lib/cellect/server/adapters/default.rb) provides an API for defining the data to be used with the system.

We're overriding the default adapter with a customization in [cellect_panoptes](https://github.com/zooniverse/cellect_panoptes).


## Cellect::Client

Provides a mix of asynchronous and synchronous operations for server awareness and API communication.


## Building

1. Install [Boost V1.55+](http://www.boost.org/): OS X: `brew update && brew install boost`, Ubuntu: `sudo apt-get update && sudo apt-get install libboost-all-dev`
2. Install gem dependencies: `bundle` (See Note)


### Note
To install rice your Ruby must be compiled with shared libraries enabled, from the rice docs:
* rvm:   `rvm reinstall [version] -- --enable-shared`
* rbenv: `CONFIGURE_OPTS="--enable-shared" rbenv install [version]`


## Testing

Run the specs with `rake`
