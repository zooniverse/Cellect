require 'diff_set'
require 'cellect'
require 'celluloid/autostart'
require 'cellect/attention'

module Cellect
  module Server
    require 'cellect/server/node_set'
    require 'cellect/server/adapters'
    require 'cellect/server/workflow'
    require 'cellect/server/grouped_workflow'
    require 'cellect/server/user'
    require 'cellect/server/api'

    class << self
      attr_accessor :node_set
    end

    # The server is ready when all workflows have finished loading
    def self.ready?
      Workflow.all.each do |workflow|
        return false unless workflow.ready?
      end

      true
    rescue
      false
    end

    def self.node_set
      @node_set ||= NodeSet.new
    end

    # Connects this server to the node set
    def self.connect
      node_set
    end
  end
end
