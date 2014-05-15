require 'cellect'

module Cellect
  module Client
    require 'cellect/client/node_set'
    require 'cellect/client/connection'
    
    class << self
      attr_accessor :connection, :_node_set
    end
    
    def self.node_set
      self._node_set ||= NodeSet.supervise
      _node_set.actors.first
    end
    
    def self.ready?
      node_set.ready?
    end
    
    def self.choose_host
      node_set.nodes.values.sample
    end
    
    Client.node_set
    Client.connection = Connection.pool size: ENV.fetch('CELLECT_POOL_SIZE', 100).to_i
  end
end
