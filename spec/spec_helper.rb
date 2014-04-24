%w(lib ext).each do |name|
  dir = File.expand_path name, File.join(File.dirname(__FILE__), '../')
  $LOAD_PATH.unshift dir unless $LOAD_PATH.include? dir
end

require 'cellect'

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
end
