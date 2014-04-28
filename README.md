# Cellect

This is a work in progress

## Building

1. Install [Boost](http://www.boost.org/): OS X: `brew update && brew install boost`, Ubuntu: `sudo apt-get update && sudo apt-get install libboost-all-dev`
2. Install gem dependencies: `bundle` (See Note)
3. Build extension: `cd ext; ruby extconf.rb; make; cd ..`

### Note
To install rice your Ruby must be compiled with shared libraries enabled, from the rice docs: 
* rvm:   `rvm reinstall [version] -- --enable-shared`
* rbenv: `CONFIGURE_OPTS="--enable-shared" rbenv install [version]`


## Testing

Run the specs with `rake`
