require 'cellect/node_set'

module Cellect
  module Client
    class NodeSet < Cellect::NodeSet
      attr_accessor :nodes

      # Sets up an empty node set
      def initialize(zk_url = nil)
        self.nodes = { }
        super
      end

      protected

      # Respond to a node coming online or timing out
      def nodes_changed(nodes)
        self.nodes = { }
        nodes.each do |node|
          self.nodes[node] = zk.get("/nodes/#{ node }").first
        end
      end

      # Register with ZooKeeper and get the list of nodes
      def setup
        watch_nodes
        zk.mkdir_p '/nodes'
        nodes_changed zk.children('/nodes', watch: true)
      end

      # Watch ZooKeeper for changes to the node set
      def watch_nodes
        zk.register('/nodes') do |event|
          nodes_changed zk.children('/nodes', watch: true)
        end
      end
    end
  end
end
