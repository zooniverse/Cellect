require 'celluloid/io'
require 'http'
require 'uri'
require 'cellect/node_set'

module Cellect
  class Replicator
    include Celluloid
    include Celluloid::IO
    
    def initialize
      NodeSet.instance
    end
    
    def replicate(method, path, query = '')
      NodeSet.nodes.each_pair do |node_id, host|
        async._replicate host, method, path, query
      end
    end
    
    def ready?
      NodeSet.ready?
    end
    
    def id
      NodeSet.id
    end
    
    def nodes
      NodeSet.nodes
    end
    
    protected
    
    def _replicate(host, method, path, query)
      uri = URI::HTTP.build host: host, path: path, query: query
      HTTP.send method, uri.to_s, socket_class: Celluloid::IO::TCPSocket
    end
  end
end
