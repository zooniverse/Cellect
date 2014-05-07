CELLECT_ROOT = File.expand_path File.join(File.dirname(__FILE__), '../')

%w(lib ext).each do |name|
  dir = File.join CELLECT_ROOT, name
  $LOAD_PATH.unshift dir unless $LOAD_PATH.include? dir
end

Bundler.require :test, :development

require 'pry'
require './spec/support/zk_setup.rb'
require 'cellect'
require 'celluloid/rspec'
require 'rack/test'
Celluloid.shutdown_timeout = 1
Celluloid.logger = nil

Dir["./spec/support/**/*.rb"].sort.each{ |f| require f }

Cellect.adapter = SpecAdapter.new
SET_TYPES = %w(random priority pairwise_random pairwise_priority)

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
  config.include CellectHelper
  
  config.around(:each) do |example|
    Celluloid.boot
    example.run
    Celluloid.shutdown
  end
  
  config.after(:suite) do
    `zkServer stop #{ CELLECT_ZK_CONFIG } > /dev/null 2>&1`
  end
end
