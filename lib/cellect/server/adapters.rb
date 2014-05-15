module Cellect
  module Server
    class << self
      attr_accessor :adapter
    end
    
    module Adapters
      require 'cellect/server/adapters/default'
    end
    
    Cellect::Server.adapter = Adapters::Default.new
  end
end
