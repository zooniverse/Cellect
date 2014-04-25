require 'oj'

module Cellect
  class User
    include Celluloid
    include Stateful
    
    attr_accessor :name, :project_name, :seen
    attr_accessor :ttl, :ttl_timer
    
    def initialize(name, project_name: nil, ttl: nil)
      self.name = name
      self.project_name = project_name
      self.seen = DiffSet::RandomSet.new
      @ttl = ttl
      subscribe 'User::state_change', :state_changed
      after(1){ fake_ready } # fake it until data loading is in place
    end
    
    def seen
      restart_ttl_timer
      @seen
    end
    
    def fake_ready
      transition :ready
    end
    
    def state_changed(topic, state)
      restart_ttl_timer if state == :ready && ttl
    end
    
    def restart_ttl_timer
      self.ttl_timer ||= after(ttl){ ttl_expired! }
      ttl_timer.reset
    end
    
    def ttl_expired!
      if project_name
        Project[project_name].remove_user name
      else
        terminate
      end
    end
    
    def ttl
      @ttl || 60 * 60 # 1 hour
    end
  end
end
