%w(lib ext).each do |name|
  dir = File.expand_path name, File.dirname(__FILE__)
  $LOAD_PATH.unshift dir unless $LOAD_PATH.include? dir
end

require 'cellect/server'

require 'cellect/server/adapters/postgres'
Cellect::Server.adapter = Cellect::Server::Adapters::Postgres.new

Cellect::Server.adapter.load_workflows
run Cellect::Server::API
