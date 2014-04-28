%w(lib ext).each do |name|
  dir = File.expand_path name, File.dirname(__FILE__)
  $LOAD_PATH.unshift dir unless $LOAD_PATH.include? dir
end

require 'pry'
require 'cellect'

run Cellect::API
