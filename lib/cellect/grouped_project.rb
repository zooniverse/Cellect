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
        group ||= klass.new
        group(hash['group_id']).add hash['id'], hash['priority']
      end
      
      transition :ready
    end
    
    def load_data_from(path)
      load_json(path) do |json|
        json['entries'].each do |entry|
          self.groups[entry['group_id']] ||= DiffSet::RandomSet.new
          groups[entry['group_id']].add entry['id']
        end
      end
    end
    
    def group(group_id = nil)
      groups[group_id] || groups.values.sample
    end
    
    def unseen_for(user_name, group_id: nil, limit: 5)
      group(group_id).subtract user(user_name).seen, limit
    end
  end
end
