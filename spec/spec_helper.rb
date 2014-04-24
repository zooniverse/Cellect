%w(lib ext).each do |name|
  dir = File.expand_path name, File.join(File.dirname(__FILE__), '../')
  $LOAD_PATH.unshift dir unless $LOAD_PATH.include? dir
end
Dir["./spec/support/**/*.rb"].sort.each{ |f| require f }

require 'pry'
require 'cellect'
require 'celluloid/rspec'
Celluloid.shutdown_timeout = 1
Celluloid.logger = nil

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
  
  config.around(:each) do |example|
    Celluloid.boot
    example.run
    Celluloid.shutdown
  end
end
