require 'cellect/node_set'

module Cellect
  module Client
    class NodeSet < Cellect::NodeSet
      attr_accessor :nodes
      
      def initialize
        self.nodes = { }
        super
      end
      
      protected
      
      def nodes_changed(nodes)
        self.nodes = { }
        nodes.each do |node|
          self.nodes[node] = zk.get("/nodes/#{ node }").first
        end
      end
      
      def setup
        watch_nodes
        zk.mkdir_p '/nodes'
        nodes_changed zk.children('/nodes', watch: true)
      end
      
      def watch_nodes
        zk.register('/nodes') do |event|
          nodes_changed zk.children('/nodes', watch: true)
        end
      end
    end
  end
end
