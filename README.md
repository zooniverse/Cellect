# Cellect [![Build Status](https://travis-ci.org/zooniverse/Cellect.svg?branch=master)](https://travis-ci.org/zooniverse/Cellect)

This is a work in progress

## Building

1. Install [Boost V1.55](http://www.boost.org/): OS X: `brew update && brew install boost`, Ubuntu: `sudo apt-get update && sudo apt-get install libboost-all-dev`
2. Install gem dependencies: `bundle` (See Note)


### Note
To install rice your Ruby must be compiled with shared libraries enabled, from the rice docs: 
* rvm:   `rvm reinstall [version] -- --enable-shared`
* rbenv: `CONFIGURE_OPTS="--enable-shared" rbenv install [version]`


## Testing

Run the specs with `rake`
