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
    
    def user(name)
      self.users[name] ||= User.new_link name, project_name: self.name
    end
    
    def unseen_for(user_name, limit: 5)
      subjects.subtract user(user_name).seen, limit
    end
    
    def add_seen_for(user_name, *subject_ids)
      [subject_ids].flatten.compact.each do |subject_id|
        user(user_name).seen.add subject_id
      end
    end
    
    def remove_user(name)
      removed = self.users.delete name
      return unless removed
      unlink removed
      removed.terminate
    end
    
    protected
    
    def load_json(path)
      transition :initializing
      yield Oj.strict_load File.read path
      transition :ready
    end
  end
end
