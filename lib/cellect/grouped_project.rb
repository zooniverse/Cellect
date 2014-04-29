require 'oj'

module Cellect
  class GroupedProject < Project
    attr_accessor :groups
    
    def initialize(name)
      super
      self.groups = { }
    end
    
    def load_data(data)
      transition :initializing
      self.subjects = set_klass.new
      klass = set_klass
      
      data.each do |hash|
        self.groups[hash['group_id']] ||= klass.new
        self.groups[hash['group_id']].add hash['id'], hash['priority']
      end
      
      transition :ready
    end
    
    def group(group_id = nil)
      groups[group_id] || groups.values.sample
    end
    
    def unseen_for(user_name, group_id: nil, limit: 5)
      group(group_id).subtract user(user_name).seen, limit
    end
    
    def sample(opts = { })
      group(opts[:group_id]).sample opts[:limit]
    end
  end
end
