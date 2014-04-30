require 'oj'

module Cellect
  class GroupedProject < Project
    attr_accessor :groups
    
    def initialize(name, pairwise: false, prioritized: false)
      super
      self.groups = { }
    end
    
    def load_data
      transition :initializing
      klass = set_klass
      Cellect.adapter.load_data_for(self).each do |hash|
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
      if opts[:user_id]
        unseen_for opts[:user_id], group_id: opts[:group_id], limit: opts[:limit]
      else
         group(opts[:group_id]).sample opts[:limit]
      end
    end
    
    def add(opts = { })
      if prioritized?
        group(opts[:group_id]).add opts[:subject_id], opts[:priority]
      else
        group(opts[:group_id]).add opts[:subject_id]
      end
    end
    
    def status
      group_counts = Hash[*groups.collect{ |id, set| [id, set.size] }.flatten]
      
      super.merge({
        grouped: true,
        subjects: group_counts.values.inject(:+),
        groups: group_counts
      })
    end
    
    def grouped?
      true
    end
  end
end
