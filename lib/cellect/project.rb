require 'oj'

module Cellect
  class Project
    include Celluloid
    include Celluloid::FSM
    include Celluloid::Notifications
    
    attr_accessor :name, :users, :subjects
    
    state :initializing
    state :ready
    
    def self.[](name)
      Actor["project_#{ name }".to_sym] ||= new name
    end
    
    def self.inherited(descendant)
      descendant.class_eval do
        state :initializing
        state :ready
      end
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
    
    def transition(new_state, opts = { })
      super(new_state, opts).tap do
        publish "Project::state_change", new_state
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
