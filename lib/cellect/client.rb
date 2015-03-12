require 'cellect'

module Cellect
  module Client
    require 'cellect/client/node_set'
    require 'cellect/client/connection'
    
    class << self
      attr_accessor :connection, :_node_set
    end
    
    # Sets up the set of server nodes
    def self.node_set(zk_url=nil)
      self._node_set ||= NodeSet.supervise(zk_url)
      _node_set.actors.first
    end
    
    def self.ready?
      node_set.ready?
    end
    
    # Selects a server for a user
    def self.choose_host
      node_set.nodes.values.sample
    end
    
    # Ensure a previously selected server is still available
    def self.host_exists?(ip)
      node_set.nodes.values.include? ip
    end
    
    if defined?(::Rails)
      require 'cellect/client/railtie'
    else
      Client.node_set
      Client.connection = Connection.pool size: ENV.fetch('CELLECT_POOL_SIZE', 100).to_i
    end
  end
end
