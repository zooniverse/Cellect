module Cellect
  module Server
    class NodeSet
      attr_reader :instance

      # Registers this server instance
      def initialize
        Attention.activate
        @instance = Attention.instance
      end
    end
  end
end
