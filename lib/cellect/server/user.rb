module Cellect
  module Server
    class User
      include Celluloid
      include Celluloid::Logger
      
      trap_exit :workflow_crashed
      finalizer :cancel_ttl_timer
      
      attr_accessor :id, :workflow_name, :seen, :state
      attr_accessor :ttl, :ttl_timer
      
      def initialize(id, workflow_name: nil, ttl: nil)
        self.id = id
        self.workflow_name = workflow_name
        self.seen = DiffSet::RandomSet.new
        monitor Workflow[workflow_name]
        @ttl = ttl
        load_data
      end
      
      def load_data
        data = Cellect::Server.adapter.load_user(workflow_name, id) || []
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
      
      def cancel_ttl_timer
        ttl_timer.cancel if ttl_timer
        self.ttl_timer = nil
      end
      
      def ttl_expired!
        debug "User #{ id } TTL expired"
        cancel_ttl_timer
        Workflow[workflow_name].async.remove_user(id)
      end
      
      def ttl
        @ttl || 60 * 15 # 15 minutes
      end
      
      def workflow_crashed(actor, reason)
        cancel_ttl_timer
        terminate
      end
    end
  end
end
