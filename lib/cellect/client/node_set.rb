module Cellect
  module Client
    class NodeSet
      attr_accessor :nodes

      # Gets the current list of nodes and listens to changes
      def initialize
        self.nodes = Attention.instances
        Attention.on_change do |change, instances|
          self.nodes = instances
        end
      end
    end
  end
end
