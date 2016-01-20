require 'cellect'

module Cellect
  module Client
    require 'cellect/client/node_set'
    require 'cellect/client/connection'

    # Sets up the set of server nodes
    def self.node_set
      @node_set ||= NodeSet.new
    end

    def self.connection
      @connection ||= Connection.new
    end

    # Selects a server for a user
    def self.choose_host
      host = node_set.nodes.sample
      host && host['ip']
    end

    # Ensure a previously selected server is still available
    def self.host_exists?(ip)
      node_set.nodes.select{ |node| node['ip'] == ip }.length > 0
    end
  end
end
