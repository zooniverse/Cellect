require 'cellect/node_set'
require 'socket'

module Cellect
  module Server
    class NodeSet < Cellect::NodeSet
      attr_accessor :id
      
      protected
      
      def setup
        zk.mkdir_p '/nodes'
        address = Socket.ip_address_list.find{ |address| address.ipv4? && !address.ipv4_loopback? }
        raise "Cannot identify IP address" unless address
        path = zk.create '/nodes/node', data: address.ip_address, mode: :ephemeral_sequential
        self.id = path.sub /^\/nodes\//, ''
      end
    end
  end
end
