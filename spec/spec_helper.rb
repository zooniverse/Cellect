require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

CELLECT_ROOT = File.expand_path File.join(File.dirname(__FILE__), '../')

%w(lib ext).each do |name|
  dir = File.join CELLECT_ROOT, name
  $LOAD_PATH.unshift dir unless $LOAD_PATH.include? dir
end

Bundler.require :test, :development

require 'pry'
require 'oj'
require 'cellect/server'
require 'cellect/client'
require 'celluloid/rspec'
require 'rack/test'
Celluloid.shutdown_timeout = 1
Celluloid.logger = nil
Dir["./spec/support/**/*.rb"].sort.each{ |f| require f }

Cellect::Server.adapter = SpecAdapter.new
SET_TYPES = %w(random priority pairwise_random pairwise_priority)

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
  config.include CellectHelper

  config.around(:each) do |example|
    Redis.new.flushall
    Celluloid.boot
    example.run
    Celluloid.shutdown
    Attention.deactivate
  end
end
