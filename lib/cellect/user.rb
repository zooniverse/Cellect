require 'oj'

module Cellect
  class User
    include Celluloid
    include Stateful
    
    attr_accessor :name, :seen
    attr_accessor :ttl, :ttl_timer
    
    def initialize(name, ttl: nil)
      self.name = name
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
      self.ttl_timer ||= after(ttl){ terminate }
      ttl_timer.reset
    end
    
    def ttl
      @ttl || 60 * 60 # 1 hour
    end
  end
end
