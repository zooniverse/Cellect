require 'oj'

module Cellect
  class GroupedProject < Project
    attr_accessor :groups
    
    def initialize(name)
      super
      self.groups = { }
    end
    
    def load_data_from(path)
      load_json(path) do |json|
        json['entries'].each do |entry|
          self.groups[entry['group_id']] ||= DiffSet::RandomSet.new
          groups[entry['group_id']].add entry['id']
        end
      end
    end
  end
end
