require 'oj'

module Cellect
  class Project
    include Celluloid
    include Stateful
    
    attr_accessor :name, :users, :subjects
    
    def self.[](name)
      Actor["project_#{ name }".to_sym] ||= new name
    end
    
    def initialize(name)
      self.name = name
      self.users = { }
      self.subjects = DiffSet::RandomSet.new
    end
    
    def load_data_from(path)
      load_json(path) do |json|
        json['entries'].each{ |id| subjects.add id }
      end
    end
    
    protected
    
    def load_json(path)
      transition :initializing
      yield Oj.strict_load File.read path
      transition :ready
    end
  end
end
