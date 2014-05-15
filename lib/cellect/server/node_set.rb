require 'cellect/node_set'
require 'socket'

module Cellect
  module Server
    class NodeSet < Cellect::NodeSet
      attr_accessor :id
      
      protected
      
      def setup
        zk.mkdir_p '/nodes'
        ip = Socket.ip_address_list.find{ |address| address.ipv4? && !address.ipv4_loopback? }.ip_address
        path = zk.create '/nodes/node', data: ip, mode: :ephemeral_sequential
        self.id = path.sub /^\/nodes\//, ''
      end
    end
  end
end
