require 'oj'

module Cellect
  class User
    include Celluloid
    include Stateful
    
    attr_accessor :id, :project_name, :seen
    attr_accessor :ttl, :ttl_timer
    
    def initialize(id, project_name: nil, ttl: nil)
      self.id = id
      self.project_name = project_name
      self.seen = DiffSet::RandomSet.new
      @ttl = ttl
      subscribe 'User::state_change', :state_changed
      async.load_data
    end
    
    def load_data
      Cellect.adapter.load_user(project_name, id).each do |subject_id|
        @seen.add subject_id
      end
      transition :ready
    end
    
    def seen
      restart_ttl_timer
      @seen
    end
    
    def state_changed(topic, state)
      restart_ttl_timer if state == :ready && ttl
    end
    
    def restart_ttl_timer
      self.ttl_timer ||= after(ttl){ ttl_expired! }
      ttl_timer.reset
    end
    
    def ttl_expired!
      Project[project_name].remove_user(id) if project_name
      terminate
    end
    
    def ttl
      @ttl || 60 * 60 # 1 hour
    end
  end
end
