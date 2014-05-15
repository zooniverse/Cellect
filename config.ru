%w(lib ext).each do |name|
  dir = File.expand_path name, File.dirname(__FILE__)
  $LOAD_PATH.unshift dir unless $LOAD_PATH.include? dir
end

require 'pry'
require 'cellect/server'
# require_relative 'spec/support/spec_adapter'
# Cellect::Server.adapter = SpecAdapter.new

require 'cellect/server/adapters/postgres'
Cellect::Server.adapter = Cellect::Server::Adapters::Postgres.new

Cellect::Server.adapter.load_projects
run Cellect::Server::API
