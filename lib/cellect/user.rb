require 'oj'

module Cellect
  class User
    include Celluloid
    
    trap_exit :project_crashed
    
    attr_accessor :id, :project_name, :seen, :state
    attr_accessor :ttl, :ttl_timer
    
    class << self
      attr_accessor :expiries_since_gc
    end
    
    self.expiries_since_gc = 0
    
    def initialize(id, project_name: nil, ttl: nil)
      self.id = id
      self.project_name = project_name
      self.seen = DiffSet::RandomSet.new
      monitor Project[project_name]
      @ttl = ttl
      load_data
    end
    
    def load_data
      data = Cellect.adapter.load_user(project_name, id) || []
      data.each do |subject_id|
        @seen.add subject_id
      end
      self.state = :ready
      restart_ttl_timer
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
      cleanup!
      Project[project_name].remove_user(id) if project_name
      terminate
    end
    
    def ttl
      @ttl || 60 * 15 # 15 minutes
    end
    
    def project_crashed(actor, reason)
      cleanup!
      terminate
    end
    
    def cleanup!
      self.seen = nil
      self.class.expiries_since_gc += 1
      if self.class.expiries_since_gc > 50
        GC.start
        self.class.expiries_since_gc = 0
      end
    end
  end
end
