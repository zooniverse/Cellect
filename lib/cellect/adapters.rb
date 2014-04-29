module Cellect
  class << self
    attr_accessor :adapter
  end
  
  module Adapters
    require 'cellect/adapters/default'
  end
  
  Cellect.adapter = Adapters::Default.new
end
