require 'cellect'
require 'celluloid/autostart'

module Cellect
  module Server
    require 'cellect/server/node_set'
    require 'cellect/server/adapters'
    require 'cellect/server/project'
    require 'cellect/server/grouped_project'
    require 'cellect/server/user'
    require 'cellect/server/api'
    
    class << self
      attr_accessor :node_set
    end
    
    def self.ready?
      Project.all.each do |project|
        return false unless project.ready?
      end
      
      true
    rescue
      false
    end
    
    Server.node_set = NodeSet.supervise
  end
end
